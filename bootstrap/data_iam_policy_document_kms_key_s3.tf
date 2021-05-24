data "aws_iam_policy_document" "kms_key_s3" {
  statement {
    sid    = "AllowLocalIAMAdministration"
    effect = "Allow"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root",
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToUse"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyPair",
      "kms:GenerateDataKeyPairWithoutPlaintext",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncrypt",
    ]

    resources = [
      "*",
    ]

    principals {
      type        = "AWS"
      identifiers = local.ro_principals
    }
  }
}
