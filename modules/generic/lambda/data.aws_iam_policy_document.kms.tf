data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowServicesToUse"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "Service"

      identifiers = [
        "sns.${var.aws["url_suffix"]}",
        "events.${var.aws["url_suffix"]}",
        "lambda.${var.aws["url_suffix"]}"
      ]
    }
  }
}
