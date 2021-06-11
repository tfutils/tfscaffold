locals {
  ro_principals = compact(distinct(flatten([
    var.tfscaffold_ro_principals,
    "arn:aws:iam::${var.aws_account_id}:root",
  ])))
}
