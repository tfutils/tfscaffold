output "availability_zones" {
  description = "The Availability Zones"
  value       = data.aws_availability_zones.available
}

output "internet_gateway" {
  description = "The Internet Gateway"
  value       = aws_internet_gateway.main
}

output "nat" {
  description = "NAT Gateway Configuration"

  value = var.nat == null ? null : var.nat["gateway_count"] == 0 ? null : {
    gateways     = aws_nat_gateway.main
    subnets      = module.subnets_nat
    eips         = aws_eip.nat
    route_tables = aws_route_table.private_nat
  }
}

output "route53_resolver_log_group" {
  description = "The Route53 Resolver Log Group"
  value       = aws_cloudwatch_log_group.route53_resolver
}

output "route_tables" {
  description = "The Route Tables"

  value = {
    public      = aws_route_table.public
    private     = aws_route_table.private
    private_nat = var.nat == null ? null : var.nat["gateway_count"] == 0 ? null : aws_route_table.private_nat
  }
}

output "route53_zone" {
  description = "The Route53 Hosted Zone"
  value       = var.root_domain_name == null ? null : aws_route53_zone.main[0]
}

output "vpc" {
  description = "The VPC"
  value       = aws_vpc.main
}

output "vpc_dhcp_options" {
  description = "The VPC DHCP Options"
  value       = aws_vpc_dhcp_options.main
}

output "vpc_gateway_endpoints" {
  description = "The VPC Gateway Endpoints"

  value = {
    dynamodb = aws_vpc_endpoint.dynamodb
    s3       = aws_vpc_endpoint.s3
  }
}
