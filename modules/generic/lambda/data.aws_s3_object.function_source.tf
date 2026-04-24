data "aws_s3_object" "function_source" {
  # Skip if using placeholder (destroy operations) or not S3 source
  count = (
    var.function_source_type == "s3"
    && !can(regex("__DESTROY_PLACEHOLDER__", var.function_source_s3_key))
  ) ? 1 : 0

  bucket     = var.function_source_s3_bucket
  key        = var.function_source_s3_key
  version_id = var.function_source_version_id
}
