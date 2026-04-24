resource "aws_cloudwatch_metric_alarm" "lambda_memory" {
  count = var.function_memory == null ? 0 : var.function_memory["alarm"] == null ? 0 : 1

  alarm_name          = coalesce(var.function_memory["alarm"]["name"], "${local.unique_id}-memory-high")
  alarm_description   = coalesce(var.function_memory["alarm"]["description"], "Memory usage > ${var.function_memory["alarm"]["threshold_percent"]}% for Lambda ${local.unique_id}")
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.function_memory["alarm"]["evaluation_periods"]

  # Use metric math to calculate percentage of allocated memory
  metric_query {
    id          = "memory_used"
    return_data = false

    metric {
      metric_name = "MaxMemoryUsed"
      namespace   = "AWS/Lambda"
      period      = var.function_memory["alarm"]["period"]
      stat        = "Maximum"

      dimensions = {
        FunctionName = aws_lambda_function.main.function_name
      }
    }
  }

  metric_query {
    id          = "memory_percent"
    expression  = "(memory_used / ${var.memory}) * 100"
    label       = "Memory Used %"
    return_data = true
  }

  threshold = var.function_memory["alarm"]["threshold_percent"]

  alarm_actions = compact(distinct(concat(
    var.function_memory["alarm"]["actions"],
    var.function_memory["alarm"]["managed_sns_topic"] ? [module.sns[0].topic["arn"]] : [],
  )))

  ok_actions = compact(distinct(concat(
    var.function_memory["alarm"]["ok_actions"],
    var.function_memory["alarm"]["managed_sns_topic"] ? tolist([module.sns[0].topic["arn"]]) : tolist([]),
  )))

  insufficient_data_actions = var.function_memory["alarm"]["insufficient_data_actions"]

  tags = merge(local.default_tags, { Name = "${local.unique_id}-lambda-memory" })
}
