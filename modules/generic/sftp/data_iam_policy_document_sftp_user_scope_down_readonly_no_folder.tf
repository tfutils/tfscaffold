data "aws_iam_policy_document" "sftp_user_scope_down_readonly_no_folder" {
  version = "2012-10-17"

  statement {
    sid    = "AllowListingOfUserFolder"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::$${transfer:HomeBucket}",
    ]
  }

  statement {
    sid    = "HomeDirObjectAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "arn:aws:s3:::$${transfer:HomeDirectory}*",
    ]
  }

  statement {
    sid    = "AllowAnyKmsActionsGrantedByUserRole"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]
  }
}
