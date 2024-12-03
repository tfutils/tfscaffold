resource "aws_s3_bucket" "main" {
  bucket        = "${local.unique_id_global}-${var.bucket_name}"
  force_destroy = true

  tags = merge(local.default_tags, { Name = "${local.unique_id_global}-${var.bucket_name}" })
}
