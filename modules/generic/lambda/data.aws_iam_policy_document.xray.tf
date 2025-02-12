data "aws_iam_policy_document" "xray" {
  statement {
    sid    = "AllowXRay"
    effect = "Allow"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
    ]

    resources = [
      "*",
    ]
  }
}
