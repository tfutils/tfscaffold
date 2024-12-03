resource "aws_sns_topic" "main" {
  name              = local.topic_name
  display_name      = local.topic_display_name
  kms_master_key_id = var.kms_master_key_id
  delivery_policy   = var.delivery_policy
  signature_version = var.signature_version
  fifo_topic        = var.fifo_topic

  application_failure_feedback_role_arn    = local.feedback_config["application"]["failure_role_arn"]
  application_success_feedback_role_arn    = local.feedback_config["application"]["success_role_arn"]
  application_success_feedback_sample_rate = local.feedback_config["application"]["success_sample_rate"]

  firehose_failure_feedback_role_arn    = local.feedback_config["firehose"]["failure_role_arn"]
  firehose_success_feedback_role_arn    = local.feedback_config["firehose"]["success_role_arn"]
  firehose_success_feedback_sample_rate = local.feedback_config["firehose"]["success_sample_rate"]

  http_failure_feedback_role_arn    = local.feedback_config["http"]["failure_role_arn"]
  http_success_feedback_role_arn    = local.feedback_config["http"]["success_role_arn"]
  http_success_feedback_sample_rate = local.feedback_config["http"]["success_sample_rate"]

  lambda_failure_feedback_role_arn    = local.feedback_config["lambda"]["failure_role_arn"]
  lambda_success_feedback_role_arn    = local.feedback_config["lambda"]["success_role_arn"]
  lambda_success_feedback_sample_rate = local.feedback_config["lambda"]["success_sample_rate"]

  sqs_failure_feedback_role_arn    = local.feedback_config["sqs"]["failure_role_arn"]
  sqs_success_feedback_role_arn    = local.feedback_config["sqs"]["success_role_arn"]
  sqs_success_feedback_sample_rate = local.feedback_config["sqs"]["success_sample_rate"]

  tags = local.default_tags

  depends_on = [
    aws_cloudwatch_log_group.main,
  ]
}
