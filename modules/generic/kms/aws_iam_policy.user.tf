# Create the Key Policy for the AWS KMS Key
resource "aws_iam_policy" "user" {
  count = var.create_policies ? 1 : 0

  name   = "${local.unique_id_account}-user"
  path   = "/"
  policy = data.aws_iam_policy_document.user.json

  tags = merge(local.default_tags, { Name = "${local.unique_id_account}-user" })
}
