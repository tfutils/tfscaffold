data "external" "insights_layer_arn" {
  count  = !var.edge && var.insights["enabled"] && var.insights["fetch"] ? 1 : 0

  program = compact([
    "node",
    "${path.module}/files/get-lambda-insights-layer-arn/dist/index.js",
    var.architectures[0],
    local.region,
    var.insights["version"],
  ])
}
