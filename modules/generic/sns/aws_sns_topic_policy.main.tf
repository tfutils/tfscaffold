resource "aws_sns_topic_policy" "main" {
  count  = local.topic_policy_required ? 1 : 0
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.sns[0].json
}

