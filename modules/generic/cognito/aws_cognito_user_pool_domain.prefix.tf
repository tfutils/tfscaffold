resource "aws_cognito_user_pool_domain" "prefix" {
  count = local.custom_domain ? 0 : 1

  domain       = local.user_pool_domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}
