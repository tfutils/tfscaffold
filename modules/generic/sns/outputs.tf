output "topic" {
  value = aws_sns_topic.main
}

output "topic_policy" {
  value = local.topic_policy_required ? aws_sns_topic_policy.main[0] : null
}

output "feedback_config" {
  value = local.feedback_config
}
