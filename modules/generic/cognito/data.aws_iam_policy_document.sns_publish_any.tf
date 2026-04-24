# Cognito uses sns:Publish to send SMS messages (MFA, verification codes)
# directly to phone number endpoints, not to specific SNS topic ARNs.
# This cannot be scoped to a specific resource ARN without breaking SMS
# functionality. AWS documents this as the expected pattern.
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
