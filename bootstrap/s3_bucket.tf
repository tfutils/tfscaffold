resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  force_destroy = "false"

  versioning {
    enabled = "true"
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
