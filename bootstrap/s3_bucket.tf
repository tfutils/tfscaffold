resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = "false"

  # This does not use default tag map merging because bootstrapping is special
  # You should use default tag map merging elsewhere
  tags = {
    Name        = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    Environment = var.environment
    Project     = var.project
    Component   = var.component
    Account     = var.aws_account_id
  }
}
