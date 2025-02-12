# TODO: Check if this ALARM NAME needs to match a specific standard pattern
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.function_errors == null ? 0 : var.function_errors["alarm"] == null ? 0 : 1

  alarm_name                = coalesce(var.function_errors["alarm"]["name"], "${local.unique_id}-errors")
  alarm_description         = coalesce(var.function_errors["alarm"]["description"], "Errors > 0 for Lambda ${local.unique_id}")
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = var.function_errors["alarm"]["evaluation_periods"]
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = var.function_errors["alarm"]["period"]
  statistic                 = var.function_errors["alarm"]["statistic"]
  threshold                 = var.function_errors["alarm"]["threshold"]

  alarm_actions = compact(distinct(concat(
    var.function_errors["alarm"]["actions"],
    var.function_errors["alarm"]["managed_sns_topic"] ? [module.sns[0].topic["arn"]] : [],
  )))

  ok_actions = compact(distinct(concat(
    var.function_errors["alarm"]["ok_actions"],
    var.function_errors["alarm"]["managed_sns_topic"] ? tolist([module.sns[0].topic["arn"]]) : tolist([]),
  )))

  insufficient_data_actions = var.function_errors["alarm"]["insufficient_data_actions"]

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = merge(local.default_tags, { Name = "${local.unique_id}-lambda-errors" })
}
