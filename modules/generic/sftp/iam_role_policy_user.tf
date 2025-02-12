resource "aws_iam_role_policy" "user" {
  for_each = toset(local.buckets)

  name   = "${local.csi}-${each.key}-user"
  role   = aws_iam_role.user[each.key].id
  policy = data.aws_iam_policy_document.sftp_user[each.key].json
}
