resource "aws_iam_role_policy" "cognito_user_pool_sms" {
  count = var.sms_enabled ? 1 : 0

  name = "${local.unique_id}-user-pool-sms"
  role = aws_iam_role.cognito_user_pool_sms[0].id

  policy = data.aws_iam_policy_document.sns_publish_any.json
}
