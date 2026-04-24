resource "aws_s3_bucket_accelerate_configuration" "main" {
  count = var.accelerate_configuration ? 1 : 0

  bucket = aws_s3_bucket.main.id
  status = "Enabled"
}
