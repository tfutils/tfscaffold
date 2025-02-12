data "aws_iam_policy_document" "lambda_custom" {
  count = length(var.iam_policy_documents) == 0 ? 0 : 1

  source_policy_documents = var.iam_policy_documents
}
