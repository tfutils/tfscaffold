resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  force_destroy = true

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags = merge(
    local.default_tags,
    {
      Name = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    }
  )
}
