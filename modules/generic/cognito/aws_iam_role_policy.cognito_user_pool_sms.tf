resource "aws_iam_role_policy" "cognito_user_pool_sms" {
  name = "${local.unique_id}-user-pool-sms"
  role = aws_iam_role.cognito_user_pool_sms.id

  # TODO: Scope this down!
  policy = data.aws_iam_policy_document.sns_publish_any.json
}
