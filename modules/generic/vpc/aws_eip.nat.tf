# Elastic IPs, one for each NAT Gateway
resource "aws_eip" "nat" {
  count = var.nat == null ? 0 : var.nat["gateway_count"]

  domain = "vpc"

  tags = merge(local.default_tags, { Name = "${local.unique_id}-nat-${element(local.nat_availability_zones, count.index)}" })
}
