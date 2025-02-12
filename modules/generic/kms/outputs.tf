output "key_arn" {
  value = aws_kms_key.main.arn
}

output "key_id" {
  value = aws_kms_key.main.key_id
}

output "key_alias" {
  value = var.alias != null ? aws_kms_alias.main[0].arn : null
}

output "admin_policy_arn" {
  value = var.create_policies ? aws_iam_policy.admin[0].arn : null
}

output "admin_policy_json" {
  value = data.aws_iam_policy_document.admin.json
}

output "user_policy_arn" {
  value = var.create_policies ? aws_iam_policy.user[0].arn : null
}

output "user_policy_json" {
  value = data.aws_iam_policy_document.user.json
}
