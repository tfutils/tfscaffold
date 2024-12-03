data "aws_iam_policy_document" "sns" {
  count = local.topic_policy_required ? 1 : 0

  source_policy_documents = var.iam_policy_documents

  dynamic "statement" {
    for_each = length(var.publishing_service_principals) > 0 ? [1] : []

    content {
      sid    = "AllowServicePrincipalsPublish"
      effect = "Allow"

      actions = [
        "SNS:Publish",
      ]

      principals {
        type        = "Service"
        identifiers = var.publishing_service_principals
      }

      resources = [
        aws_sns_topic.main.arn,
      ]
    }
  }
}

