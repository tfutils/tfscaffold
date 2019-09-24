resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  force_destroy = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix  = "/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = merge(local.default_tags,
    map(
      "Name", "Terraform Scaffold TFState bucket"
    )
  )
}
