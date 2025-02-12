data "aws_iam_policy_document" "lambda_assumerole" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = compact([
        "lambda.${var.aws["url_suffix"]}",
        var.edge ? "edgelambda.${var.aws["url_suffix"]}" : null,
      ])
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

