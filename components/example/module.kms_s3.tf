module "kms_s3" {
  source = "../../modules/generic/kms"

  aws = local.aws

  unique_ids = {
    local   = "${local.unique_id}-kms-s3"
    account = "${local.unique_id_account}-kms-s3"
  }

  alias           = "alias/s3/${local.unique_id}"
  create_policies = false
  deletion_window = 30
}
