locals {
  module = "sns"

  aws_account_id = var.aws["account_id"]
  region         = var.aws["region"]

  unique_id         = var.unique_ids["local"]
  unique_id_account = var.unique_ids["account"]
  unique_id_global  = var.unique_ids["global"]

  default_tags = merge(
    var.aws["default_tags"],
    {
      "Name"             = local.unique_id
      "terraform:module" = local.module
    },
    length(var.module_parents) == 0 ? {} : {
      "terraform:module:parents" = join(":", var.module_parents)
    },
  )
}
