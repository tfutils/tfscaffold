data "aws_lambda_layer_version" "insights" {
  count = !var.edge && var.insights["enabled"] && var.insights["fetch"] ? 1 : 0

  layer_name = "arn:${local.lambda_insights_partition}:lambda:${local.region}:${local.lambda_insights_account_id}:layer:${local.lambda_insights_layer_name}"
}
