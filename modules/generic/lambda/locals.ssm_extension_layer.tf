# AWS Parameters and Secrets Lambda Extension layer.
# Published by AWS in different accounts per region. Account IDs are the same
# for x86_64 and arm64 architectures; only the layer name and version differ.
# Cross-account ListLayerVersions/GetLayerVersion is not granted by AWS.
#
# Source: AWS CDK fact-tables.ts PARAMS_AND_SECRETS_LAMBDA_LAYER_ARNS (1.0.103)
# https://github.com/aws/aws-cdk/blob/main/packages/aws-cdk-lib/region-info/build-tools/fact-tables.ts

locals {
  ssm_extension_account_ids = {
    "af-south-1"     = "317013901791"
    "ap-east-1"      = "768336418462"
    "ap-northeast-1" = "133490724326"
    "ap-northeast-2" = "738900069198"
    "ap-northeast-3" = "576959938190"
    "ap-south-1"     = "176022468876"
    "ap-south-2"     = "070087711984"
    "ap-southeast-1" = "044395824272"
    "ap-southeast-2" = "665172237481"
    "ap-southeast-3" = "490737872127"
    "ca-central-1"   = "200266452380"
    "cn-north-1"     = "287114880934"
    "cn-northwest-1" = "287310001119"
    "eu-central-1"   = "187925254637"
    "eu-central-2"   = "772501565639"
    "eu-north-1"     = "427196147048"
    "eu-south-1"     = "325218067255"
    "eu-south-2"     = "524103009944"
    "eu-west-1"      = "015030872274"
    "eu-west-2"      = "133256977650"
    "eu-west-3"      = "780235371811"
    "me-central-1"   = "858974508948"
    "me-south-1"     = "832021897121"
    "sa-east-1"      = "933737806257"
    "us-east-1"      = "177933569100"
    "us-east-2"      = "590474943231"
    "us-gov-east-1"  = "129776340158"
    "us-gov-west-1"  = "127562683043"
    "us-west-1"      = "997803712105"
    "us-west-2"      = "345057560386"
  }

  ssm_extension_account_id = lookup(
    local.ssm_extension_account_ids,
    local.region,
    null
  )

  ssm_extension_layer_name = (
    var.architectures[0] == "arm64"
    ? "AWS-Parameters-and-Secrets-Lambda-Extension-Arm64"
    : "AWS-Parameters-and-Secrets-Lambda-Extension"
  )

  ssm_extension_layer_arn = (
    var.function_source_type == "image" ? [] :
    var.edge ? [] :
    !var.ssm_extension["enabled"] ? [] :
    local.ssm_extension_account_id == null ? [] :
    ["arn:${local.lambda_insights_partition}:lambda:${local.region}:${local.ssm_extension_account_id}:layer:${local.ssm_extension_layer_name}:${var.ssm_extension["version"]}"]
  )

  ssm_extension_env_vars = var.ssm_extension["enabled"] ? {
    PARAMETERS_SECRETS_EXTENSION_HTTP_PORT     = tostring(var.ssm_extension["http_port"])
    PARAMETERS_SECRETS_EXTENSION_CACHE_ENABLED = "true"
    SSM_PARAMETER_STORE_TTL                    = tostring(var.ssm_extension["cache_ttl"])
  } : {}
}
