output "arn" {
  value = aws_iam_role.main.arn
}

output "name" {
  value = aws_iam_role.main.name
}

output "policy_arn" {
  value = var.create_policy ? aws_iam_policy.main[0].arn : null
}
