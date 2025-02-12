resource "aws_transfer_ssh_key" "main" {
  for_each  = var.users
  server_id = aws_cloudformation_stack.transfer_server.outputs.id
  user_name = each.key
  body      = each.value.public_key

  depends_on = [
    aws_transfer_user.main,
  ]
}
