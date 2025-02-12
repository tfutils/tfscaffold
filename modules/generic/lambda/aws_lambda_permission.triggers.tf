resource "aws_lambda_permission" "triggers" {
  for_each = { for k, v in var.allowed_triggers : k => v }

  function_name = aws_lambda_function.main.function_name

  statement_id       = try(each.value.statement_id, each.key)
  action             = try(each.value.action, "lambda:InvokeFunction")
  principal          = try(each.value.principal, format("%s.${var.aws["url_suffix"]}", try(each.value.service, "")))
  source_arn         = try(each.value.source_arn, null)
  source_account     = try(each.value.source_account, null)
  event_source_token = try(each.value.event_source_token, null)
}

