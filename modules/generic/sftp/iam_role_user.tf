resource "aws_iam_role" "user" {
  for_each = toset(local.buckets)

  name               = "${each.key}-sftp"
  assume_role_policy = data.aws_iam_policy_document.transfer_assumerole.json
}
