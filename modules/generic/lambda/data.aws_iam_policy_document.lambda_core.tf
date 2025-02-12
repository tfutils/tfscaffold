data "aws_iam_policy_document" "lambda_core" {
  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.main.arn}:*",
    ]
  }

  statement {
    sid    = "AllowXRay"
    effect = "Allow"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = var.insights["enabled"] ? [1] : []

    content {
      sid    = "AllowInsightsLogging"
      effect = "Allow"

      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]

      resources = [
        "arn:aws:logs:${local.region}:${local.aws_account_id}:log-group:/aws/lambda-insights:*",
      ]
    }
  }

  dynamic "statement" {
    for_each = local.managed_sns_topic ? [1] : []

    content {
      sid    = "AllowLambdaToPublishToTopic"
      effect = "Allow"

      actions = [
        "sns:Publish",
      ]

      resources = [
        module.sns[0].topic["arn"],
      ]
    }
  }

  dynamic "statement" {
    for_each = local.managed_sns_topic ? [1] : []

    content {
      sid    = "AllowEncryptedSnsActions"
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
      ]

      resources = [
        module.kms.key_arn,
      ]
    }
  }

  dynamic "statement" {
    for_each = var.vpc_config == null ? [] : [1]

    content {
      sid    = "AllowCreateNetworkInterface"
      effect = "Allow"

      actions = [
        "ec2:CreateNetworkInterface",
      ]

      resources = concat(
        formatlist("arn:aws:ec2:%s:%s:subnet/%s", local.region, local.aws_account_id, var.vpc_config["subnet_ids"]),
        formatlist("arn:aws:ec2:%s:%s:security-group/%s", local.region, local.aws_account_id, var.vpc_config["security_group_ids"]),
        ["arn:aws:ec2:${local.region}:${local.aws_account_id}:network-interface/*"],
      )
    }
  }

  dynamic "statement" {
    for_each = var.vpc_config == null ? [] : [1]

    content {
      sid    = "AllowNetworkManagement"
      effect = "Allow"

      actions = [
        "ec2:AssignPrivateIpAddress",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:UnassignPrivateIpAddress",
      ]

      resources = [
        "*",
      ]
    }
  }
}
