resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform_state_lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

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