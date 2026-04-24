# AWS Distro for OpenTelemetry (ADOT) Node.js Lambda layer.
# Account 901920570463 is the same across all commercial, China, and GovCloud
# regions. The SDK version is part of the layer name; the layer version is
# always 1 for each SDK release. Cross-account ListLayerVersions is not
# granted by AWS, so the ARN is constructed directly.
#
# Source: AWS CDK fact-tables.ts ADOT_LAMBDA_LAYER_JAVASCRIPT_SDK_ARNS
# https://github.com/aws/aws-cdk/blob/main/packages/aws-cdk-lib/region-info/build-tools/fact-tables.ts

locals {
  adot_account_id  = "901920570463"
  adot_arch_suffix = var.architectures[0] == "arm64" ? "arm64" : "amd64"

  adot_layer_arn = (
    var.function_source_type == "image" ? [] :
    var.edge ? [] :
    !var.adot["enabled"] ? [] :
    ["arn:${local.lambda_insights_partition}:lambda:${local.region}:${local.adot_account_id}:layer:aws-otel-nodejs-${local.adot_arch_suffix}-ver-${var.adot["sdk_version"]}:1"]
  )

  adot_env_vars = var.adot["enabled"] ? {
    AWS_LAMBDA_EXEC_WRAPPER     = "/opt/otel-handler"
    OTEL_TRACES_EXPORTER        = "otlp"
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
    OTEL_PROPAGATORS            = "tracecontext,baggage,xray"
    OTEL_RESOURCE_ATTRIBUTES    = "service.name=${local.function_name}"
  } : {}
}
