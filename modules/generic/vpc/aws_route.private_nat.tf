# The route(s) to the NAT Gateway(s) for the private_nat route table(s)
resource "aws_route" "private_nat_nat_gateways" {
  count = var.nat == null ? 0 : var.nat["gateway_count"]

  route_table_id         = aws_route_table.private_nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}