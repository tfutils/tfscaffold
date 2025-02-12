# One route table per NAT Gateway that provides an route to the Internet
# via that gateway.
#
# For one NAT Gateway in one AZ to serve subnets in multiple AZs, provide this route table to each consumer subnet
# For one NAT Gateway per AZ, provide aws_route_table.private_nat[count.index] to each route table association
resource "aws_route_table" "private_nat" {
  count = var.nat == null ? 0 : var.nat["gateway_count"]

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.unique_id}-private-nat/${element(local.nat_availability_zones, count.index)}"
      Type = "private-nat"
    }
  )
}
