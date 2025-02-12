resource "aws_iam_policy" "lambda_core" {
  name        = "${local.unique_id_account}-lambda-core"
  description = "Core execution policy for the ${local.function_name} Lambda Function"
  policy      = data.aws_iam_policy_document.lambda_core.json

  tags = merge(local.default_tags, { Name = "${local.unique_id_account}-lambda-core" })
}
