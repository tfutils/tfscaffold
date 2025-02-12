resource "aws_iam_policy" "lambda_custom" {
  count = length(var.iam_policy_documents) == 0 ? 0 : 1

  name        = "${local.unique_id_account}-lambda-custom"
  description = "Additional custom execution policy for ${local.function_name} Lambda"
  policy      = data.aws_iam_policy_document.lambda_custom[0].json

  tags = merge(local.default_tags, { Name = "${local.unique_id_account}-lambda-custom" })
}
