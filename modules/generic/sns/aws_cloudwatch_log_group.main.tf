resource "aws_cloudwatch_log_group" "main" {
  name = format(
    "sns/%s/%s/%s",
    local.region,
    local.aws_account_id,
    local.topic_name,
  )

  retention_in_days = var.log_retention_in_days

  tags = local.default_tags
}
