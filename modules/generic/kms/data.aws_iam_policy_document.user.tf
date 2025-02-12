data "aws_iam_policy_document" "user" {
  policy_id = "${local.unique_id}-user"

  statement {
    sid    = "AllowUseOfTheKmskey"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      aws_kms_key.main.arn,
    ]
  }

  statement {
    sid    = "AllowDelegationToAwsServiceViaGrant"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
    ]

    resources = [
      aws_kms_key.main.arn,
    ]

    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true",
      ]
    }
  }
}

