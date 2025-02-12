data "aws_iam_policy_document" "sftp_logs_write" {
  version = "2012-10-17"

  statement {
    sid    = "AllowCreateDescribeAndWriteLogStream"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.main.arn}:*",
    ]
  }
}
