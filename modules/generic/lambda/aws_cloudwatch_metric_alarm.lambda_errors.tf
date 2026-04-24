# Lambda Errors Alarm - supports both count and percentage thresholds
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.function_errors == null ? 0 : var.function_errors["alarm"] == null ? 0 : 1

  alarm_name          = coalesce(var.function_errors["alarm"]["name"], "${local.unique_id}-errors")
  alarm_description   = coalesce(var.function_errors["alarm"]["description"], "Errors > ${var.function_errors["alarm"]["threshold"]}${var.function_errors["alarm"]["threshold_type"] == "percentage" ? "%" : ""} for Lambda ${local.unique_id}")
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.function_errors["alarm"]["evaluation_periods"]

  # For count mode: use simple metric
  # For percentage mode: use metric math to calculate error rate
  dynamic "metric_query" {
    for_each = var.function_errors["alarm"]["threshold_type"] == "percentage" ? [1] : []

    content {
      id          = "errors"
      return_data = false

      metric {
        metric_name = "Errors"
        namespace   = "AWS/Lambda"
        period      = var.function_errors["alarm"]["period"]
        stat        = "Sum"

        dimensions = {
          FunctionName = aws_lambda_function.main.function_name
        }
      }
    }
  }

  dynamic "metric_query" {
    for_each = var.function_errors["alarm"]["threshold_type"] == "percentage" ? [1] : []

    content {
      id          = "invocations"
      return_data = false

      metric {
        metric_name = "Invocations"
        namespace   = "AWS/Lambda"
        period      = var.function_errors["alarm"]["period"]
        stat        = "Sum"

        dimensions = {
          FunctionName = aws_lambda_function.main.function_name
        }
      }
    }
  }

  dynamic "metric_query" {
    for_each = var.function_errors["alarm"]["threshold_type"] == "percentage" ? [1] : []

    content {
      id          = "error_rate"
      expression  = "(errors / invocations) * 100"
      label       = "Error Rate %"
      return_data = true
    }
  }

  # For count mode only
  metric_name = var.function_errors["alarm"]["threshold_type"] != "percentage" ? "Errors" : null
  namespace   = var.function_errors["alarm"]["threshold_type"] != "percentage" ? "AWS/Lambda" : null
  period      = var.function_errors["alarm"]["threshold_type"] != "percentage" ? var.function_errors["alarm"]["period"] : null
  statistic   = var.function_errors["alarm"]["threshold_type"] != "percentage" ? var.function_errors["alarm"]["statistic"] : null

  threshold = var.function_errors["alarm"]["threshold"]

  alarm_actions = compact(distinct(concat(
    var.function_errors["alarm"]["actions"],
    var.function_errors["alarm"]["managed_sns_topic"] ? [module.sns[0].topic["arn"]] : [],
  )))

  ok_actions = compact(distinct(concat(
    var.function_errors["alarm"]["ok_actions"],
    var.function_errors["alarm"]["managed_sns_topic"] ? tolist([module.sns[0].topic["arn"]]) : tolist([]),
  )))

  insufficient_data_actions = var.function_errors["alarm"]["insufficient_data_actions"]

  dimensions = var.function_errors["alarm"]["threshold_type"] != "percentage" ? {
    FunctionName = aws_lambda_function.main.function_name
  } : null

  tags = merge(local.default_tags, { Name = "${local.unique_id}-lambda-errors" })
}
