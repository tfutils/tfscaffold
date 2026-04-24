data "aws_iam_policy_document" "assumerole" {
  count = var.trusted_principals != null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    dynamic "principals" {
      for_each = var.trusted_principals != null ? var.trusted_principals : []
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }

    dynamic "condition" {
      for_each = length([
        for p in coalesce(var.trusted_principals, []) : p.external_id
        if p.external_id != null
      ]) > 0 ? [1] : []

      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values = [
          for p in coalesce(var.trusted_principals, []) : p.external_id
          if p.external_id != null
        ]
      }
    }
  }
}
