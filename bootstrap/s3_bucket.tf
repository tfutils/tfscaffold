resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  force_destroy = "false"

  versioning {
    enabled = "true"
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    prefix  = "/"
    enabled = "true"

    noncurrent_version_transition {
      days          = "30"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = "60"
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = "90"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags {
    "Name"        = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    "Environment" = "${var.environment}"
    "Project"     = "${var.project}"
    "Component"   = "${var.component}"
    "Account"     = "${var.aws_account_id}"
  }
}

resource "aws_s3_bucket_policy" "terraform_remote_state" {
  bucket = "${aws_s3_bucket.bucket.id}"
  policy = "${data.aws_iam_policy_document.terraform_remote_state.json}"
}

data "aws_iam_policy_document" "terraform_remote_state" {
  statement {
    sid       = "RequireEncryptedTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "RequireEncryptedStorage"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_remote_state" {
  # https://github.com/terraform-providers/terraform-provider-aws/issues/7628
  depends_on = ["aws_s3_bucket_policy.terraform_remote_state"]

  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
