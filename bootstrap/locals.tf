locals {
  default_tags = {
    Account     = var.aws_account_id
    Project     = var.project
    Environment = var.environment
    Component   = var.component
  }
}
