resource "aws_iam_role" "cognito_user_pool_sms" {
  name               = "${local.unique_id}-user-pool-sms"
  assume_role_policy = data.aws_iam_policy_document.cognito_user_pool_assumerole.json

  tags = merge(
    local.default_tags,
    {
      Name = "${local.unique_id}-user-pool-sms"
    }
  )

  provisioner "local-exec" {
    command = "sleep 10"
  }
}
