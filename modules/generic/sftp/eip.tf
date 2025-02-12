resource "aws_eip" "main" {
  count = var.sftp_endpoint_type == "VPC" ? length(var.subnet_ids) : 0
  vpc   = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.csi}-${data.aws_availability_zones.available.names[count.index]}"
    },
  )
}
