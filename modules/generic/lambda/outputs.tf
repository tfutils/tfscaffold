output "cloudwatch_event_rule_name" {
  value = var.schedule == "" ? null : aws_cloudwatch_event_rule.main[0].name
}

output "cloudwatch_event_rule_arn" {
  value = var.schedule == "" ? null : aws_cloudwatch_event_rule.main[0].arn
}

output "cloudwatch_event_target_id" {
  value = var.schedule == "" ? null : aws_cloudwatch_event_target.main[0].id
}

output "iam_role_arn" {
  value = aws_iam_role.main.arn
}

output "iam_role_name" {
  value = aws_iam_role.main.name
}

output "iam_role_policy_attachment_lambda_core" {
  value = aws_iam_role_policy_attachment.lambda_core
}

output "iam_role_policy_attachment_lambda_custom" {
  value = length(var.iam_policy_documents) == 0 ? null : aws_iam_role_policy_attachment.lambda_custom[0]
}

output "lambda_function_arn" {
  value = aws_lambda_function.main.arn
}

output "lambda_function_environment" {
  value = aws_lambda_function.main.environment
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.main.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.main.function_name
}

output "lambda_function_qualified_arn" {
  value = aws_lambda_function.main.qualified_arn
}

output "lambda_function_version" {
  value = aws_lambda_function.main.version
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.main.name
}

output "sns_topic_arn" {
  value = local.managed_sns_topic ? module.sns[0].topic["arn"] : null
}
