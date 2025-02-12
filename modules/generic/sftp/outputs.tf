output "endpoint" {
  value = aws_cloudformation_stack.transfer_server.outputs.endpoint
}

output "server_id" {
  value = aws_cloudformation_stack.transfer_server.outputs.id
}

output "users" {
  value = aws_transfer_user.main
}

output "user_iam_role_names" {
  value = values(aws_iam_role.user)[*].name
}

output "user_iam_role_arns" {
  value = values(aws_iam_role.user)[*].arn
}

output "security_group_id" {
  value = var.sftp_endpoint_type != "PUBLIC" ? aws_security_group.main[0].id : null
}

output "eips" {
  value = var.sftp_endpoint_type == "VPC" ? aws_eip.main[*].public_ip : null
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.main.name
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.main.arn
}
