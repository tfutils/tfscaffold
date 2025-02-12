resource "aws_iam_role" "main" {
  name               = local.unique_id_account
  assume_role_policy = data.aws_iam_policy_document.lambda_assumerole.json

  tags = merge(local.default_tags, { Name = local.unique_id_account })

  # Le sigh
  provisioner "local-exec" {
    command = "sleep 10"
  }
}
