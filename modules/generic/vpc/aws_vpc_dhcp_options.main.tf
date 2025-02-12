# A DHCP Options Set for the VPC
resource "aws_vpc_dhcp_options" "main" {
  domain_name = local.vpc_domain_name

  domain_name_servers = [
    "AmazonProvidedDNS",
  ]

  tags = local.default_tags
}
