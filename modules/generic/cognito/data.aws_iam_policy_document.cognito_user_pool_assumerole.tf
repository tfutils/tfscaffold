data "aws_iam_policy_document" "cognito_user_pool_assumerole" {
  statement {
    sid    = "WebCognitoUserPoolAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cognito-idp.${var.aws["url_suffix"]}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        "${local.unique_id}-user-pool",
      ]
    }
  }
}
