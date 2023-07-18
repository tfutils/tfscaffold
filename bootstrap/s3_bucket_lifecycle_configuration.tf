resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket                = aws_s3_bucket.bucket.id
  expected_bucket_owner = var.aws_account_id

  rule {
    id     = "default"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_transition {
      noncurrent_days = "30"
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = "60"
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = "90"
    }
  }
}
