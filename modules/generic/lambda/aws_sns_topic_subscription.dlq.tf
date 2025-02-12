# Used for subscribing external resources such as OpsGenie
resource "aws_sns_topic_subscription" "dlq" {
  count = local.managed_sns_topic ? length(var.subscription_arns) : 0

  topic_arn = module.sns[0].topic["arn"]
  protocol  = var.subscription_arns[count.index]["protocol"]
  endpoint  = var.subscription_arns[count.index]["endpoint"]

  endpoint_auto_confirms = lookup(
    var.subscription_arns[count.index],
    "endpoint_auto_confirms",
    "false",
  )

  confirmation_timeout_in_minutes = lookup(
    var.subscription_arns[count.index],
    "confirmation_timeout_in_minutes",
    "1",
  )

  raw_message_delivery = lookup(
    var.subscription_arns[count.index],
    "raw_message_delivery",
    "false",
  )

  filter_policy = lookup(
    var.subscription_arns[count.index],
    "filter_policy",
    "",
  )
}
