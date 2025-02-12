locals {
  archive_path = "${path.root}/work/${local.unique_id_global}/function.zip"

  # Annoyingly the "aws_lambda_layer_version" data source doesn't return
  # anything for the LambdaInsightsExtension, so we have to hack it like this:

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versionsx86-64.html
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
    var.insights["fetch"] ? [ data.external.insights_layer_arn[0].result.layerArn ] :
    [ local.lambda_insight_layer_arns[var.architectures[0]][var.architectures[0] == "arm64" ? "1.0.333.0" : "1.0.143.0"][local.region] ]
  )

  layers = var.edge ? null : concat(
    local.lambda_insights_layer_arn,
    var.layers
  )

  managed_sns_topic = var.function_errors == null ? false : anytrue([
    var.function_errors["alarm"] != null ? var.function_errors["alarm"]["managed_sns_topic"] : false,
    var.function_errors["async_on_failure_destination"] != null ? var.function_errors["async_on_failure_destination"]["managed_sns_topic"] : false,
  ])
}
