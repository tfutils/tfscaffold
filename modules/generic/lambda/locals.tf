locals {
  archive_path = "${path.root}/work/${local.unique_id_global}/function.zip"

  # Lambda Insights layers are published by AWS in different accounts per region
  # and architecture. The data source resolves the latest version automatically
  # via ListLayerVersions. Account IDs sourced from AWS CDK fact-tables.ts:
  # https://github.com/aws/aws-cdk/blob/main/packages/aws-cdk-lib/region-info/build-tools/fact-tables.ts
  # Default account (580247275435) covers most commercial regions.

  lambda_insights_account_ids = {
    "x86_64" = {
      "af-south-1"     = "012438385374"
      "ap-east-1"      = "519774774795"
      "ap-east-2"      = "145023102084"
      "ap-south-2"     = "891564319516"
      "ap-southeast-3" = "439286490199"
      "ap-southeast-4" = "158895979263"
      "ap-southeast-5" = "590183865173"
      "ap-southeast-6" = "727646510379"
      "ap-southeast-7" = "761018874580"
      "ap-northeast-3" = "194566237122"
      "ca-west-1"      = "946466191631"
      "cn-north-1"     = "488211338238"
      "cn-northwest-1" = "488211338238"
      "eu-central-2"   = "033019950311"
      "eu-south-1"     = "339249233099"
      "eu-south-2"     = "352183217350"
      "il-central-1"   = "459530977127"
      "mx-central-1"   = "879381266642"
      "me-south-1"     = "285320876703"
      "me-central-1"   = "732604637566"
      "us-gov-east-1"  = "122132214140"
      "us-gov-west-1"  = "751350123760"
    }
    "arm64" = {
      "af-south-1"     = "012438385374"
      "ap-east-1"      = "519774774795"
      "ap-south-2"     = "891564319516"
      "ap-southeast-3" = "439286490199"
      "ap-southeast-4" = "605207715842"
      "ap-northeast-3" = "194566237122"
      "ca-west-1"      = "761377655185"
      "cn-north-1"     = "488211338238"
      "cn-northwest-1" = "488211338238"
      "eu-central-2"   = "033019950311"
      "eu-south-1"     = "339249233099"
      "eu-south-2"     = "352183217350"
      "il-central-1"   = "066549572091"
      "me-south-1"     = "285320876703"
      "me-central-1"   = "732604637566"
      "us-gov-east-1"  = "198461476570"
      "us-gov-west-1"  = "198461476570"
    }
  }

  lambda_insights_arch = var.architectures[0] == "arm64" ? "arm64" : "x86_64"

  lambda_insights_account_id = lookup(
    local.lambda_insights_account_ids[local.lambda_insights_arch],
    local.region,
    "580247275435"
  )

  lambda_insights_partition = (
    startswith(local.region, "cn-") ? "aws-cn" :
    startswith(local.region, "us-gov-") ? "aws-us-gov" :
    "aws"
  )

  lambda_insights_layer_name = (
    var.architectures[0] == "arm64"
    ? "LambdaInsightsExtension-Arm64"
    : "LambdaInsightsExtension"
  )

  # Hardcoded fallback maps for when fetch is disabled (insights.fetch = false).
  # These provide known-good ARNs without requiring ListLayerVersions permission.
  lambda_insight_layer_arns = {
    "x86_64" = {
      "1.0.143.0" = {
        "us-east-1"      = "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension:21"
        "us-east-2"      = "arn:aws:lambda:us-east-2:580247275435:layer:LambdaInsightsExtension:21"
        "us-west-1"      = "arn:aws:lambda:us-west-1:580247275435:layer:LambdaInsightsExtension:20"
        "us-west-2"      = "arn:aws:lambda:us-west-2:580247275435:layer:LambdaInsightsExtension:21"
        "af-south-1"     = "arn:aws:lambda:af-south-1:012438385374:layer:LambdaInsightsExtension:13"
        "ap-east-1"      = "arn:aws:lambda:ap-east-1:519774774795:layer:LambdaInsightsExtension:13"
        "ap-south-1"     = "arn:aws:lambda:ap-south-1:580247275435:layer:LambdaInsightsExtension:21"
        "ap-northeast-3" = "arn:aws:lambda:ap-northeast-3:194566237122:layer:LambdaInsightsExtension:2"
        "ap-northeast-2" = "arn:aws:lambda:ap-northeast-2:580247275435:layer:LambdaInsightsExtension:20"
        "ap-southeast-1" = "arn:aws:lambda:ap-southeast-1:580247275435:layer:LambdaInsightsExtension:21"
        "ap-southeast-2" = "arn:aws:lambda:ap-southeast-2:580247275435:layer:LambdaInsightsExtension:21"
        "ap-northeast-1" = "arn:aws:lambda:ap-northeast-1:580247275435:layer:LambdaInsightsExtension:32"
        "ca-central-1"   = "arn:aws:lambda:ca-central-1:580247275435:layer:LambdaInsightsExtension:20"
        "eu-central-1"   = "arn:aws:lambda:eu-central-1:580247275435:layer:LambdaInsightsExtension:21"
        "eu-west-1"      = "arn:aws:lambda:eu-west-1:580247275435:layer:LambdaInsightsExtension:21"
        "eu-west-2"      = "arn:aws:lambda:eu-west-2:580247275435:layer:LambdaInsightsExtension:21"
        "eu-south-1"     = "arn:aws:lambda:eu-south-1:339249233099:layer:LambdaInsightsExtension:13"
        "eu-west-3"      = "arn:aws:lambda:eu-west-3:580247275435:layer:LambdaInsightsExtension:20"
        "eu-north-1"     = "arn:aws:lambda:eu-north-1:580247275435:layer:LambdaInsightsExtension:20"
        "me-south-1"     = "arn:aws:lambda:me-south-1:285320876703:layer:LambdaInsightsExtension:13"
        "sa-east-1"      = "arn:aws:lambda:sa-east-1:580247275435:layer:LambdaInsightsExtension:20"
      }
    }

    "arm64" = {
      "1.0.333.0" = {
        "us-east-1"      = "arn:aws:lambda:us-east-1:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "us-east-2"      = "arn:aws:lambda:us-east-2:580247275435:layer:LambdaInsightsExtension-Arm64:22"
        "us-west-1"      = "arn:aws:lambda:us-west-1:580247275435:layer:LambdaInsightsExtension-Arm64:18"
        "us-west-2"      = "arn:aws:lambda:us-west-2:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "af-south-1"     = "arn:aws:lambda:af-south-1:012438385374:layer:LambdaInsightsExtension-Arm64:18"
        "ap-east-1"      = "arn:aws:lambda:ap-east-1:519774774795:layer:LambdaInsightsExtension-Arm64:18"
        "ap-south-2"     = "arn:aws:lambda:ap-south-2:891564319516:layer:LambdaInsightsExtension-Arm64:6"
        "ap-southeast-3" = "arn:aws:lambda:ap-southeast-3:439286490199:layer:LambdaInsightsExtension-Arm64:18"
        "ap-south-1"     = "arn:aws:lambda:ap-south-1:580247275435:layer:LambdaInsightsExtension-Arm64:22"
        "ap-northeast-3" = "arn:aws:lambda:ap-northeast-3:194566237122:layer:LambdaInsightsExtension-Arm64:17"
        "ap-northeast-2" = "arn:aws:lambda:ap-northeast-2:580247275435:layer:LambdaInsightsExtension-Arm64:19"
        "ap-southeast-1" = "arn:aws:lambda:ap-southeast-1:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "ap-southeast-2" = "arn:aws:lambda:ap-southeast-2:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "ap-northeast-1" = "arn:aws:lambda:ap-northeast-1:580247275435:layer:LambdaInsightsExtension-Arm64:31"
        "ca-central-1"   = "arn:aws:lambda:ca-central-1:580247275435:layer:LambdaInsightsExtension-Arm64:18"
        "eu-central-1"   = "arn:aws:lambda:eu-central-1:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "eu-west-1"      = "arn:aws:lambda:eu-west-1:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "eu-west-2"      = "arn:aws:lambda:eu-west-2:580247275435:layer:LambdaInsightsExtension-Arm64:20"
        "eu-south-1"     = "arn:aws:lambda:eu-south-1:339249233099:layer:LambdaInsightsExtension-Arm64:18"
        "eu-west-3"      = "arn:aws:lambda:eu-west-3:580247275435:layer:LambdaInsightsExtension-Arm64:18"
        "eu-north-1"     = "arn:aws:lambda:eu-north-1:580247275435:layer:LambdaInsightsExtension-Arm64:18"
        "me-south-1"     = "arn:aws:lambda:me-south-1:285320876703:layer:LambdaInsightsExtension-Arm64:18"
        "sa-east-1"      = "arn:aws:lambda:sa-east-1:580247275435:layer:LambdaInsightsExtension-Arm64:18"
      }
    }
  }

  function_name        = var.function_name != null ? var.function_name : local.unique_id
  function_description = var.function_description != null ? var.function_description : local.unique_id

  lambda_insights_layer_arn = (
    var.function_source_type == "image" ? [] :
    var.edge ? [] :
    !var.insights["enabled"] ? [] :
    var.insights["fetch"] ? [data.aws_lambda_layer_version.insights[0].arn] :
    [local.lambda_insight_layer_arns[var.architectures[0]][var.architectures[0] == "arm64" ? "1.0.333.0" : "1.0.143.0"][local.region]]
  )

  layers = var.edge ? null : concat(
    local.lambda_insights_layer_arn,
    local.adot_layer_arn,
    local.ssm_extension_layer_arn,
    var.layers
  )

  effective_env_vars = merge(
    local.adot_env_vars,
    local.ssm_extension_env_vars,
    var.lambda_env_vars
  )

  effective_xray_mode = var.adot["enabled"] ? "Active" : var.xray_mode

  managed_sns_topic = anytrue([
    var.function_errors != null ? var.function_errors["alarm"] != null ? var.function_errors["alarm"]["managed_sns_topic"] : false : false,
    var.function_errors != null ? var.function_errors["async_on_failure_destination"] != null ? var.function_errors["async_on_failure_destination"]["managed_sns_topic"] : false : false,
    var.function_memory != null ? var.function_memory["alarm"] != null ? var.function_memory["alarm"]["managed_sns_topic"] : false : false,
  ])
}
