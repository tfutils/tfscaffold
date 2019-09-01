resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform_state_lock"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    "Name"        = "Terraform Scaffold State File Bucket for account ${var.aws_account_id} in region ${var.region}"
    "Environment" = "${var.environment}"
    "Project"     = "${var.project}"
    "Component"   = "${var.component}"
    "Account"     = "${var.aws_account_id}"
  }
}
