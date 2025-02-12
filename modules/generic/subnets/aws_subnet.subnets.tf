resource "aws_subnet" "subnets" {
  count                   = length(var.cidrs)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.default_tags, { Name = "${local.unique_id}/${element(var.availability_zones, count.index)}" })
}

