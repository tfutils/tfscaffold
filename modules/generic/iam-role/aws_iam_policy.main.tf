resource "aws_iam_policy" "main" {
  count = var.create_policy ? 1 : 0

  name        = var.name
  description = "Policy for ${var.name} role"
  policy      = var.policy_document
}
