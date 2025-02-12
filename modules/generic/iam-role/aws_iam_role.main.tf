resource "aws_iam_role" "main" {
  name = var.name

  assume_role_policy = coalesce(
    var.trust_policy,
    var.trusted_principals == null ? null : data.aws_iam_policy_document.assumerole[0].json
  )
}
