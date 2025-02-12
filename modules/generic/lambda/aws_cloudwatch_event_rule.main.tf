resource "aws_cloudwatch_event_rule" "main" {
  count               = var.schedule == "" ? 0 : 1
  name                = local.unique_id
  description         = local.unique_id
  schedule_expression = var.schedule

  tags = local.default_tags
}

