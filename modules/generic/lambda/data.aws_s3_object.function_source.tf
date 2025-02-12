data "aws_s3_object" "function_source" {
  count = var.function_source_type == "s3" ? 1 : 0

  bucket     = var.function_source_s3_bucket
  key        = var.function_source_s3_key
  version_id = var.function_source_version_id
}
