module "subnets_nat" {
  count = var.nat == null ? 0 : var.nat["gateway_count"] == 0 ? 0 : 1

  source = "../subnets"

  aws = merge(
    var.aws,
    {
      default_tags = merge(
        var.aws["default_tags"],
        var.nat["subnets_default_tags"],
      ),
    },
  )

  module_parents = concat(var.module_parents, [local.module])

  unique_ids = {
    local = "${local.unique_id}-nat"
  }

  availability_zones = local.nat_availability_zones

  cidrs = [ for index in range(var.nat["gateway_count"]) :
    cidrsubnet(
      var.vpc_cidr,
      var.nat["subnets_newbits"],
      var.nat["subnets_netnum_root"] + index,
    )
  ]

  map_public_ip_on_launch = var.nat["subnets_map_public_ip_on_launch"]

  route_tables = [
    aws_route_table.public.id,
  ]

  vpc_id = aws_vpc.main.id
}
