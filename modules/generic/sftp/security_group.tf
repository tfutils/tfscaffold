resource "aws_security_group" "main" {
  count       = var.sftp_endpoint_type != "PUBLIC" ? 1 : 0
  name        = local.csi
  description = local.csi
  vpc_id      = var.vpc_id
  tags        = local.default_tags
}
