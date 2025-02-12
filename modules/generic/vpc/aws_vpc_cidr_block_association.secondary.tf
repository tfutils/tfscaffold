resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  for_each   = var.vpc_secondary_cidrs
  vpc_id     = aws_vpc.main.id
  cidr_block = each.key
}
