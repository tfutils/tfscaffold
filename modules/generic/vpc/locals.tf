locals {
  nat_availability_zones = try(var.nat["availability_zones"], null) == null ? data.aws_availability_zones.available.names : var.nat["availability_zones"]
  vpc_domain_name        = var.root_domain_name == null ? "${local.region}.compute.internal" : var.root_domain_name
}
