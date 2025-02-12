resource "aws_transfer_user" "main" {
  for_each            = var.users
  home_directory      = each.value.folder == "" ? "/${each.value.bucket}" : "/${each.value.bucket}/${each.value.folder}"
  home_directory_type = "PATH"

  policy = each.value.folder != "" ? (
    local.user_scope_down_policies[each.value.permissions]
  ) : (
    local.user_scope_down_policies["${each.value.permissions}_no_folder"]
  )

  role                = aws_iam_role.user[each.value.bucket].arn
  server_id           = aws_cloudformation_stack.transfer_server.outputs.id
  user_name           = each.key
  tags                = local.default_tags
}
