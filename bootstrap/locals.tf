locals {
  ro_principals = compact(distinct(flatten([
    var.tfscaffold_ro_principals,
    "arn:aws:iam::${var.aws_account_id}:root",
  ])))

  default_tags = {
    "tfscaffold:environment" = var.environment
    "tfscaffold:project"     = var.project
    "tfscaffold:component"   = var.component
  }
}
