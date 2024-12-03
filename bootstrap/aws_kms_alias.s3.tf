resource "aws_kms_alias" "s3" {
  name          = "alias/s3/${var.bucket_name}"
  target_key_id = aws_kms_key.s3.key_id
}
