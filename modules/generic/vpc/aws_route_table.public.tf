# Public Route Table for any public subnet within the VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.unique_id}-public"
      Type = "public"
    },
  )
}
