resource "aws_cognito_user_pool_domain" "custom" {
  count = local.custom_domain ? 1 : 0

  certificate_arn = var.custom_domain["cloudfront_acm_certificate_arn"]
  domain          = local.user_pool_domain
  user_pool_id    = aws_cognito_user_pool.main.id
}
