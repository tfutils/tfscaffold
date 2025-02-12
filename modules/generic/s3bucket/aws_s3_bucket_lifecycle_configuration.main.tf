resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.lifecycle_rules != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id = local.unique_id

    filter {
      prefix = var.lifecycle_rules.prefix
    }

    status = "Enabled"

    dynamic "noncurrent_version_transition" {
      for_each = var.lifecycle_rules.noncurrent_version_transition

      content {
        noncurrent_days = noncurrent_version_transition.value.days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }

    dynamic "transition" {
      for_each = var.lifecycle_rules.transition

      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.lifecycle_rules.noncurrent_version_expiration.days == "-1" ? [] : [ var.lifecycle_rules.noncurrent_version_expiration.days ]

      content {
        noncurrent_days = noncurrent_version_expiration.value
      }
    }

    dynamic "expiration" {
      for_each = var.lifecycle_rules.expiration.days == "-1" ? [] : [ var.lifecycle_rules.expiration.days ]

      content {
        days = expiration.value
      }
    }
  }
}
