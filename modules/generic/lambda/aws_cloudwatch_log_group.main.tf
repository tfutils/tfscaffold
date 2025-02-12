resource "aws_cloudwatch_log_group" "main" {
  # The local.unique_id is used instead of the function name
  # to avoid a dependency on the Lambda resource
  name = "/aws/lambda/${local.function_name}"

  retention_in_days = var.log_retention_in_days

  tags = local.default_tags
}
