<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | ../kms | n/a |
| <a name="module_sns"></a> [sns](#module\_sns) | ../sns | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.lambda_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.lambda_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.triggers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic_subscription.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.main](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_lambda_layer_version.insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_layer_version) | data source |
| [aws_s3_object.function_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adot"></a> [adot](#input\_adot) | AWS Distro for OpenTelemetry (ADOT) Node.js layer configuration. Ignored when edge is true. When enabled, automatically injects standard OTEL environment variables and sets X-Ray tracing to Active. Caller's lambda\_env\_vars override auto-injected defaults. | <pre>object({<br/>    enabled     = optional(bool, false)<br/>    sdk_version = optional(string, "1-30-2")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_allowed_triggers"></a> [allowed\_triggers](#input\_allowed\_triggers) | Map of allowed triggers to create Lambda permissions | `map(any)` | `{}` | no |
| <a name="input_architectures"></a> [architectures](#input\_architectures) | List of architectures to build the lambda for | `list(string)` | <pre>[<br/>  "x86_64"<br/>]</pre> | no |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_cloudwatch_event_target_input"></a> [cloudwatch\_event\_target\_input](#input\_cloudwatch\_event\_target\_input) | Optional JSON string to use as constant input for the Cloudwatch Event Target that invokes the lambda if using scheduled events | `string` | `null` | no |
| <a name="input_create_kms_policies"></a> [create\_kms\_policies](#input\_create\_kms\_policies) | Whether to create Admin and User IAM policies for the KMS key. Defaults to false | `bool` | `false` | no |
| <a name="input_dead_letter_target_arn"></a> [dead\_letter\_target\_arn](#input\_dead\_letter\_target\_arn) | The ARN of the SQS queue or SNS topic to use as the dead-letter target for the lambda function | `string` | `null` | no |
| <a name="input_edge"></a> [edge](#input\_edge) | Whether this lambda is an edge lambda | `bool` | `false` | no |
| <a name="input_function_description"></a> [function\_description](#input\_function\_description) | Description of the Lambda | `string` | `null` | no |
| <a name="input_function_dir"></a> [function\_dir](#input\_function\_dir) | Relative Lambda function directory path | `string` | `null` | no |
| <a name="input_function_errors"></a> [function\_errors](#input\_function\_errors) | Function Errors Monitoring Config<br/><br/>alarm: Config for sync invocations alarm<br/>  * name: The name of the alarm (defaults to the "${local.unique\_id}-errors")<br/>  * description: The description of the alarm (defaults to "Errors > 0 for Lambda ${local.unique\_id}")<br/>  * evaluation\_periods: The number of periods over which data is compared to the threshold<br/>  * period: The period in seconds over which the specified statistic is applied<br/>  * statistic: The statistic to apply to the alarm's data<br/>  * threshold: The value against which the specified statistic is compared<br/>  * threshold\_type: Type of threshold - "count" (absolute errors) or "percentage" (error rate %)<br/>  * actions: The list of actions to take when the alarm transitions into an ALARM state<br/>  * ok\_actions: The list of actions to take when the alarm transitions into an OK state<br/>  * insufficient\_data\_actions: The list of actions to take when the alarm transitions into an INSUFFICIENT\_DATA state<br/>  * managed\_sns\_topic: Whether to create an SNS topic for the alarm (in addition to the actions specified)<br/><br/>async\_invocations: Config for async invocations alarm<br/>  * enabled: Whether to enable the async invocations alarm<br/>  * managed\_sns\_topic: Whether to create an SNS topic and an event invoke config for error handling<br/>                       (takes precedence over the topic\_arn)<br/>  * topic\_arn: If specified, the ARN of the SNS topic to use for the async invocations alarm | <pre>object({<br/>    alarm = optional(object({<br/>      name                      = optional(string, null)<br/>      description               = optional(string, null)<br/>      evaluation_periods        = optional(number, 1)<br/>      period                    = optional(number, 120)<br/>      statistic                 = optional(string, "Maximum")<br/>      threshold                 = optional(number, 0)<br/>      threshold_type            = optional(string, "count") # "count" or "percentage"<br/>      actions                   = optional(list(string), [])<br/>      ok_actions                = optional(list(string), [])<br/>      insufficient_data_actions = optional(list(string), [])<br/>      managed_sns_topic         = optional(bool, false)<br/>    }), null)<br/><br/>    async_on_failure_destination = optional(object({<br/>      enabled           = bool<br/>      managed_sns_topic = optional(bool, false)<br/>      topic_arn         = optional(string, null)<br/>    }), {<br/>      enabled = false<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_function_file_extension"></a> [function\_file\_extension](#input\_function\_file\_extension) | The function source file extension, e.g. js or py | `string` | `null` | no |
| <a name="input_function_image_config"></a> [function\_image\_config](#input\_function\_image\_config) | The configuration for the Container Image that contains the lambda function code | <pre>object({<br/>    command           = optional(string, null)<br/>    entry_point       = optional(string, null)<br/>    working_directory = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_function_image_uri"></a> [function\_image\_uri](#input\_function\_image\_uri) | The URI for a Container Image that contains the lambda function code | `string` | `null` | no |
| <a name="input_function_memory"></a> [function\_memory](#input\_function\_memory) | Function Memory Monitoring Config<br/><br/>alarm: Config for memory usage alarm<br/>  * name: The name of the alarm (defaults to "${local.unique\_id}-memory-high")<br/>  * description: The description of the alarm (defaults to "Memory usage > {threshold\_percent}% for Lambda ${local.unique\_id}")<br/>  * evaluation\_periods: The number of periods over which data is compared to the threshold<br/>  * period: The period in seconds over which the specified statistic is applied<br/>  * threshold\_percent: Memory usage percentage threshold (default 80%)<br/>  * actions: The list of actions to take when the alarm transitions into an ALARM state<br/>  * ok\_actions: The list of actions to take when the alarm transitions into an OK state<br/>  * insufficient\_data\_actions: The list of actions to take when the alarm transitions into an INSUFFICIENT\_DATA state<br/>  * managed\_sns\_topic: Whether to create an SNS topic for the alarm (in addition to the actions specified) | <pre>object({<br/>    alarm = optional(object({<br/>      name                      = optional(string, null)<br/>      description               = optional(string, null)<br/>      evaluation_periods        = optional(number, 2)<br/>      period                    = optional(number, 300)<br/>      threshold_percent         = optional(number, 80)<br/>      actions                   = optional(list(string), [])<br/>      ok_actions                = optional(list(string), [])<br/>      insufficient_data_actions = optional(list(string), [])<br/>      managed_sns_topic         = optional(bool, false)<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_function_module_name"></a> [function\_module\_name](#input\_function\_module\_name) | The optional name of the function module as used by the lambda handler, e.g. index or exports. Concatenated with handler\_function\_name to make, `<var.function_module_name>.<var.handler_function_name>` | `string` | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Base name of this lambda | `string` | `null` | no |
| <a name="input_function_source"></a> [function\_source](#input\_function\_source) | The source code of the lambda function as a single file expressed as a string | `string` | `null` | no |
| <a name="input_function_source_archive_file_path"></a> [function\_source\_archive\_file\_path](#input\_function\_source\_archive\_file\_path) | Path to a deployable lambda function archive zip-file on disk | `string` | `null` | no |
| <a name="input_function_source_s3_bucket"></a> [function\_source\_s3\_bucket](#input\_function\_source\_s3\_bucket) | Bucket ID containing the lambda function source Zip archive | `string` | `null` | no |
| <a name="input_function_source_s3_key"></a> [function\_source\_s3\_key](#input\_function\_source\_s3\_key) | Key name of the lambda function source Zip archive, stored in an S3 bucket | `string` | `null` | no |
| <a name="input_function_source_type"></a> [function\_source\_type](#input\_function\_source\_type) | The type of function source, either s3, file, directory, image or archive | `string` | n/a | yes |
| <a name="input_function_source_version_id"></a> [function\_source\_version\_id](#input\_function\_source\_version\_id) | An optional S3 Object ID for the function source archive | `string` | `null` | no |
| <a name="input_handler_function_name"></a> [handler\_function\_name](#input\_handler\_function\_name) | The name of the lambda handler function (passed directly to the Lambda's handler option) | `string` | `"handler"` | no |
| <a name="input_iam_policy_documents"></a> [iam\_policy\_documents](#input\_iam\_policy\_documents) | An IAM Policy Document to grant the lambda function access to the API calls it needs. Should be the 'json' attribute of an aws\_iam\_policy\_document data source | `list(string)` | `[]` | no |
| <a name="input_insights"></a> [insights](#input\_insights) | Lambda insights layer configuration. Ignored when edge is true | <pre>object({<br/>    enabled = optional(bool, false)<br/>    fetch   = optional(bool, true)<br/>    version = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_lambda_env_vars"></a> [lambda\_env\_vars](#input\_lambda\_env\_vars) | Lambda environment parameters map | `map(string)` | `{}` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | Additional lambda layers to include. Ignored when edge is true | `list(string)` | `[]` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period for the CloudwatchLogs events generated by the lambda function | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory to apply to the created Lambda | `number` | n/a | yes |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Number of executions to limit Lambda to | `number` | `-1` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime to use for the lambda function | `string` | `null` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The fully qualified Cloudwatch Events schedule for when to run the lambda function, e.g. rate(1 day) or a cron() expression. Default disables all events resources | `string` | `""` | no |
| <a name="input_sns_logs"></a> [sns\_logs](#input\_sns\_logs) | The ARN of the IAM Role and Sample Rate to use for delivery feedback logging when creating an AWS SNS Topic | <pre>object({<br/>    iam_role_arn        = string<br/>    success_sample_rate = optional(number)<br/>  })</pre> | <pre>{<br/>  "iam_role_arn": null<br/>}</pre> | no |
| <a name="input_ssm_extension"></a> [ssm\_extension](#input\_ssm\_extension) | AWS Parameters and Secrets Lambda Extension configuration. Ignored when edge is true. When enabled, automatically injects extension environment variables. Caller's lambda\_env\_vars override auto-injected defaults. | <pre>object({<br/>    enabled   = optional(bool, false)<br/>    version   = optional(number, 4)<br/>    http_port = optional(number, 2773)<br/>    cache_ttl = optional(number, 60)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_subscription_arns"></a> [subscription\_arns](#input\_subscription\_arns) | List of subscriptions for the SNS topic | `list(map(string))` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds of the lambda function invocation | `number` | n/a | yes |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | n/a | <pre>object({<br/>    security_group_ids = list(string)<br/>    subnet_ids         = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_xray_mode"></a> [xray\_mode](#input\_xray\_mode) | Mode for AWS X-Ray | `string` | `"PassThrough"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_arn"></a> [cloudwatch\_event\_rule\_arn](#output\_cloudwatch\_event\_rule\_arn) | n/a |
| <a name="output_cloudwatch_event_rule_name"></a> [cloudwatch\_event\_rule\_name](#output\_cloudwatch\_event\_rule\_name) | n/a |
| <a name="output_cloudwatch_event_target_id"></a> [cloudwatch\_event\_target\_id](#output\_cloudwatch\_event\_target\_id) | n/a |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | n/a |
| <a name="output_iam_role_policy_attachment_lambda_core"></a> [iam\_role\_policy\_attachment\_lambda\_core](#output\_iam\_role\_policy\_attachment\_lambda\_core) | n/a |
| <a name="output_iam_role_policy_attachment_lambda_custom"></a> [iam\_role\_policy\_attachment\_lambda\_custom](#output\_iam\_role\_policy\_attachment\_lambda\_custom) | n/a |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | n/a |
| <a name="output_lambda_function_environment"></a> [lambda\_function\_environment](#output\_lambda\_function\_environment) | n/a |
| <a name="output_lambda_function_invoke_arn"></a> [lambda\_function\_invoke\_arn](#output\_lambda\_function\_invoke\_arn) | n/a |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | n/a |
| <a name="output_lambda_function_qualified_arn"></a> [lambda\_function\_qualified\_arn](#output\_lambda\_function\_qualified\_arn) | n/a |
| <a name="output_lambda_function_version"></a> [lambda\_function\_version](#output\_lambda\_function\_version) | n/a |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | n/a |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | n/a |
<!-- END_TF_DOCS -->
