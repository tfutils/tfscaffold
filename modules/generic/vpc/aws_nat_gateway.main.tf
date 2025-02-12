resource "aws_nat_gateway" "main" {
  count = var.nat == null ? 0 : var.nat["gateway_count"]

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(module.subnets_nat[0].subnet_ids, count.index)

  tags = local.default_tags
}
