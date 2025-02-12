resource "aws_route_table_association" "main" {
  count          = length(var.cidrs)
  subnet_id      = element(aws_subnet.subnets.*.id, count.index)
  route_table_id = element(var.route_tables, count.index)
}

