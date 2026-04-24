# The primary Route53 private hosted zone to associate
# as the default zone for the VPC
resource "aws_route53_zone" "main" {
  count = var.root_domain_name == null ? 0 : 1

  name          = var.root_domain_name
  comment       = local.unique_id
  force_destroy = true

  vpc {
    vpc_id     = aws_vpc.main.id
    vpc_region = local.region
  }

  tags = local.default_tags
}
