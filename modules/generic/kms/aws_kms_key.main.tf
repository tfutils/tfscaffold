resource "aws_kms_key" "main" {
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window
  description                        = var.description == null ? local.unique_id : "${local.unique_id} ${var.description}"
  enable_key_rotation                = var.rotation
  policy                             = data.aws_iam_policy_document.key.json

  tags = local.default_tags
}
