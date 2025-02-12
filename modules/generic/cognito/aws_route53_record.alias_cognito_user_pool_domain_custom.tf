resource "aws_route53_record" "alias_cognito_user_pool_domain_custom" {
  count = local.custom_domain ? 1 : 0

  name    = "${local.user_pool_domain}."
  type    = "A"
  zone_id = var.custom_domain["route53_public_hosted_zone_id"]

  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.custom[0].cloudfront_distribution_arn

    # Well-known Hosted Zone ID of CloudFront 
    zone_id = "Z2FDTNDATAQYW2"
  }
}
