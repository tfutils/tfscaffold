resource "aws_s3_bucket_logging" "main" {
  count  = contains(keys(var.bucket_logging_target), "bucket") ? 1 : 0
  bucket = aws_s3_bucket.main.id

  # Enable S3 Bucket Logging to the logs bucket
  target_bucket = var.bucket_logging_target["bucket"]
  target_prefix = lookup(var.bucket_logging_target, "prefix", "${local.bucket_name}/")
}
