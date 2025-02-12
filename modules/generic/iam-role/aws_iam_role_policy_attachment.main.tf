resource "aws_iam_role_policy_attachment" "main" {
  count      = var.create_policy ? 1 : 0
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main[0].arn
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = var.managed_policy_arns

  role       = aws_iam_role.main.name
  policy_arn = each.key
}
