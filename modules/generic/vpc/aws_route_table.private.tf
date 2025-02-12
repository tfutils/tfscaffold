# Private Route Table for any private subnet within the VPC
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.unique_id}-private"
      Type = "private"
    },
  )
}
