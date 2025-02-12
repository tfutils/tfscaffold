resource "aws_cloudwatch_log_group" "route53_resolver" {
  name              = "/aws/route53/resolver/${local.unique_id}"
  retention_in_days = 365

  tags = merge(local.default_tags, { Name = "${local.unique_id}-route53-resolver" })
}
