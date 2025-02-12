data "aws_iam_policy_document" "admin" {
  policy_id = "${local.unique_id}-admin"

  statement {
    sid    = "AllowKeyAdmin"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    resources = compact([
      aws_kms_key.main.arn,
      var.alias != null ? aws_kms_alias.main[0].arn : null,
    ])
  }
}

