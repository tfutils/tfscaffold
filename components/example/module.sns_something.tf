module "sns_something" {
  source = "../../modules/generic/sns"

  aws = local.aws

  module_parents = []

  unique_ids = {
    local   = "${local.unique_id}-something"
    account = "${local.unique_id_account}-something"
    global  = "${local.unique_id_global}-something"
  }
}
