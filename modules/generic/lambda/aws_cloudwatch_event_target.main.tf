resource "aws_cloudwatch_event_target" "main" {
  count     = var.schedule == "" ? 0 : 1
  arn       = aws_lambda_function.main.arn
  input     = var.cloudwatch_event_target_input
  rule      = aws_cloudwatch_event_rule.main[0].name
  target_id = local.unique_id
}
