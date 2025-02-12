data "aws_iam_policy_document" "key" {
  #checkov:skip=CKV_AWS_109:Access from local account intentional
  #checkov:skip=CKV_AWS_111:Access from local account intentional
  source_policy_documents = var.key_policy_documents

  dynamic "statement" {
    for_each = var.iam_delegation ? [1] : []
    content {
      sid    = "AllowFullLocalAdministration"
      effect = "Allow"

      principals {
        type = "AWS"

        identifiers = [
          "arn:${var.aws["partition"]}:iam::${local.aws_account_id}:root",
        ]
      }

      actions = [
        "kms:*",
      ]

      resources = [
        "*",
      ]
    }
  }
}
