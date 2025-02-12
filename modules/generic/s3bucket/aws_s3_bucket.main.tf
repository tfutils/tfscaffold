resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.default_tags, { Name = local.unique_id_global })
}
