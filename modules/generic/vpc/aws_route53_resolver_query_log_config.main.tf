resource "aws_route53_resolver_query_log_config" "main" {
  name            = local.unique_id
  destination_arn = aws_cloudwatch_log_group.route53_resolver.arn

  tags = local.default_tags
}
