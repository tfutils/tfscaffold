# TODO: Scope this down!
data "aws_iam_policy_document" "sns_publish_any" {
  statement {
    sid    = "AllowSnsPublish"
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      "*",
    ]
  }
}
