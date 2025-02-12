data "aws_iam_policy_document" "transfer_assumerole" {
  version = "2012-10-17"

  statement {
    sid = "TransferAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "transfer.amazonaws.com",
      ]
    }
  }
}
