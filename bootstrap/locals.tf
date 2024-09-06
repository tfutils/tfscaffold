locals {
  ro_principals = compact(distinct(flatten([
    var.tfscaffold_ro_principals,
    "arn:aws:iam::${var.aws_account_id}:root",
  ])))

  default_tags = {
    "tfscaffold:Environment" = var.environment
    "tfscaffold:Project"     = var.project
    "tfscaffold:Component"   = var.component
    "tfscaffold:Account"     = var.aws_account_id
  }
}
