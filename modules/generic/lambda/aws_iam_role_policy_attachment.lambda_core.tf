resource "aws_iam_role_policy_attachment" "lambda_core" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.lambda_core.arn
}
