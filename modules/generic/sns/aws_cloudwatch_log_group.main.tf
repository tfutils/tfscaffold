resource "aws_cloudwatch_log_group" "main" {
  count = local.feedback_logging_enabled ? 1 : 0

  name = format(
    "sns/%s/%s/%s",
    local.region,
    local.aws_account_id,
    local.topic_name,
  )

  retention_in_days = var.log_retention_in_days

  tags = merge(
    local.default_tags,
    {
      Name = format(
        "sns/%s/%s/%s",
        local.region,
        local.aws_account_id,
        local.topic_name,
      )
    }
  )
}
