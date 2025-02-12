module "sns" {
  count = local.managed_sns_topic ? 1 : 0

  source = "../sns"

  aws = var.aws

  module_parents = concat(var.module_parents, [local.module])

  unique_ids = {
    local = "${local.unique_id}-fail"
  }

  default_feedback_role_arn            = var.sns_logs["iam_role_arn"]
  default_success_feedback_sample_rate = coalesce(var.sns_logs["success_sample_rate"], 100)

  iam_policy_documents = [
    data.aws_iam_policy_document.sns.json,
  ]

  kms_master_key_id = module.kms.key_arn
}
