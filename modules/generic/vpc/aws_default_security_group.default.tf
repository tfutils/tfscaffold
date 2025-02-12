# Adopted so that it is disabled.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, { Name = "${local.unique_id}-default" })
}
