data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "DontAllowNonSecureConnection"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    condition {
      test = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
    ]

    principals {
      type        = "AWS"
      identifiers = local.ro_principals
    }
  }

  statement {
    sid    = "AllowManagedAccountsToGet"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = local.ro_principals
    }
  }
}
