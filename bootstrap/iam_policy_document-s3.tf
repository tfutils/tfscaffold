data "aws_iam_policy_document" "tfstate_bucket" {
  statement {
    sid     = "DenyNonSslRequests"
    effect  = "Deny"
    actions = ["*"]

    resources = [
      "${aws_s3_bucket.tfstate_bucket.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
