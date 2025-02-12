resource "aws_iam_role_policy_attachment" "lambda_custom" {
  count = length(var.iam_policy_documents) == 0 ? 0 : 1

  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.lambda_custom[0].arn
}
