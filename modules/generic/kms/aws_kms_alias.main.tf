resource "aws_kms_alias" "main" {
  count = var.alias != null ? 1 : 0

  name          = var.alias == "name" ? "alias/${local.unique_id}" : "alias/${var.alias}"
  target_key_id = aws_kms_key.main.key_id
}

