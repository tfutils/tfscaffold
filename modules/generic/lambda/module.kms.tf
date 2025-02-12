module "kms" {
  source = "../kms"

  aws = var.aws

  module_parents = concat(var.module_parents, [local.module])

  unique_ids = {
    local   = "${local.unique_id}-kms"
    account = "${local.unique_id_account}-kms"
  }

  alias           = "alias/${local.unique_id}"
  create_policies = var.create_kms_policies
  deletion_window = 30

  key_policy_documents = [
    data.aws_iam_policy_document.kms.json,
  ]
}
