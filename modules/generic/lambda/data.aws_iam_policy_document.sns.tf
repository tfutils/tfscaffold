data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "AllowEventsAndLambdaToPublishToTopic"
    effect = "Allow"

    actions = [
      "SNS:Publish",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudwatch.${var.aws["url_suffix"]}",
        "events.${var.aws["url_suffix"]}",
        "lambda.${var.aws["url_suffix"]}",
      ]
    }

    resources = [
      "*"
    ]
  }
}
