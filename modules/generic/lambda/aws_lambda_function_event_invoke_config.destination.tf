resource "aws_lambda_function_event_invoke_config" "destination" {
  count = var.function_errors == null ? 0 : var.function_errors["async_on_failure_destination"] == null ? 0 : !var.function_errors["async_on_failure_destination"]["enabled"] ? 0 : 1

  function_name = aws_lambda_function.main.function_name

  destination_config {
    on_failure {
      destination = var.function_errors["async_on_failure_destination"]["managed_sns_topic"] ? module.sns[0].topic["arn"] : var.function_errors["async_on_failure_destination"]["topic_arn"]
    }
  }

  # This depends_on is used to to avoid race condition where lambda creation is attempted
  # prior to policy being attached to role, then failing as doesn't have permission to
  # write to SNS Topic
  depends_on = [
    aws_iam_role_policy_attachment.lambda_core,
  ]
}
