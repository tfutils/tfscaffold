<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_sns_topic.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_failure_feedback_role_arn"></a> [application\_failure\_feedback\_role\_arn](#input\_application\_failure\_feedback\_role\_arn) | Role ARN for application endpoint delivery success | `string` | `null` | no |
| <a name="input_application_success_feedback_role_arn"></a> [application\_success\_feedback\_role\_arn](#input\_application\_success\_feedback\_role\_arn) | Role ARN for application endpoint delivery success | `string` | `null` | no |
| <a name="input_application_success_feedback_sample_rate"></a> [application\_success\_feedback\_sample\_rate](#input\_application\_success\_feedback\_sample\_rate) | Role ARN for application endpoint delivery success | `string` | `null` | no |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br>    account_id   = string<br>    default_tags = optional(map(string), {})<br>    partition    = optional(string, "aws")<br>    region       = string<br>    url_suffix   = optional(string, "amazonaws.com")<br>  })</pre> | n/a | yes |
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | Enables content-based deduplication for FIFO topics. | `bool` | `null` | no |
| <a name="input_default_failure_feedback_role_arn"></a> [default\_failure\_feedback\_role\_arn](#input\_default\_failure\_feedback\_role\_arn) | Default Success/Failure Feedback Role ARN for all endpoints | `string` | `null` | no |
| <a name="input_default_feedback_role_arn"></a> [default\_feedback\_role\_arn](#input\_default\_feedback\_role\_arn) | Default Success/Failure Feedback Role ARN for all endpoints | `string` | `null` | no |
| <a name="input_default_success_feedback_role_arn"></a> [default\_success\_feedback\_role\_arn](#input\_default\_success\_feedback\_role\_arn) | Default Success/Failure Feedback Role ARN for all endpoints | `string` | `null` | no |
| <a name="input_default_success_feedback_sample_rate"></a> [default\_success\_feedback\_sample\_rate](#input\_default\_success\_feedback\_sample\_rate) | Default Success Feedback Sample Rate for all endpoints | `number` | `100` | no |
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | The SNS delivery policy | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | If set, the 'Display Name' of the SNS Topic, otherwise it will be set to the same as the topic name | `string` | `null` | no |
| <a name="input_fifo_topic"></a> [fifo\_topic](#input\_fifo\_topic) | Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false). | `bool` | `false` | no |
| <a name="input_firehose_failure_feedback_role_arn"></a> [firehose\_failure\_feedback\_role\_arn](#input\_firehose\_failure\_feedback\_role\_arn) | Role ARN for firehose endpoint delivery success | `string` | `null` | no |
| <a name="input_firehose_success_feedback_role_arn"></a> [firehose\_success\_feedback\_role\_arn](#input\_firehose\_success\_feedback\_role\_arn) | Role ARN for firehose endpoint delivery success | `string` | `null` | no |
| <a name="input_firehose_success_feedback_sample_rate"></a> [firehose\_success\_feedback\_sample\_rate](#input\_firehose\_success\_feedback\_sample\_rate) | Role ARN for firehose endpoint delivery success | `string` | `null` | no |
| <a name="input_http_failure_feedback_role_arn"></a> [http\_failure\_feedback\_role\_arn](#input\_http\_failure\_feedback\_role\_arn) | Role ARN for http endpoint delivery success | `string` | `null` | no |
| <a name="input_http_success_feedback_role_arn"></a> [http\_success\_feedback\_role\_arn](#input\_http\_success\_feedback\_role\_arn) | Role ARN for http endpoint delivery success | `string` | `null` | no |
| <a name="input_http_success_feedback_sample_rate"></a> [http\_success\_feedback\_sample\_rate](#input\_http\_success\_feedback\_sample\_rate) | Role ARN for http endpoint delivery success | `string` | `null` | no |
| <a name="input_iam_policy_documents"></a> [iam\_policy\_documents](#input\_iam\_policy\_documents) | IAM Policy Documents to combine into the SNS Topic Policy, using the source\_policies parameter | `list(string)` | `[]` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | KMS CMK for Message Encryption | `string` | `null` | no |
| <a name="input_lambda_failure_feedback_role_arn"></a> [lambda\_failure\_feedback\_role\_arn](#input\_lambda\_failure\_feedback\_role\_arn) | Role ARN for lambda endpoint delivery success | `string` | `null` | no |
| <a name="input_lambda_success_feedback_role_arn"></a> [lambda\_success\_feedback\_role\_arn](#input\_lambda\_success\_feedback\_role\_arn) | Role ARN for lambda endpoint delivery success | `string` | `null` | no |
| <a name="input_lambda_success_feedback_sample_rate"></a> [lambda\_success\_feedback\_sample\_rate](#input\_lambda\_success\_feedback\_sample\_rate) | Role ARN for lambda endpoint delivery success | `string` | `null` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Log retention period in days for the feedback cloudwatch log group | `number` | `365` | no |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_publishing_service_principals"></a> [publishing\_service\_principals](#input\_publishing\_service\_principals) | A list of service principals to be granted SNS:Publish permission to the SNS topic, obviating the need to declare a whole topic policy document independently to permit it. e.g., [ codepipeline.${var.aws["url\_suffix"]} ] | `list(string)` | `[]` | no |
| <a name="input_signature_version"></a> [signature\_version](#input\_signature\_version) | If SignatureVersion should be 1 (SHA1) or 2 (SHA256). The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. | `string` | `null` | no |
| <a name="input_sqs_failure_feedback_role_arn"></a> [sqs\_failure\_feedback\_role\_arn](#input\_sqs\_failure\_feedback\_role\_arn) | Role ARN for sqs endpoint delivery success | `string` | `null` | no |
| <a name="input_sqs_success_feedback_role_arn"></a> [sqs\_success\_feedback\_role\_arn](#input\_sqs\_success\_feedback\_role\_arn) | Role ARN for sqs endpoint delivery success | `string` | `null` | no |
| <a name="input_sqs_success_feedback_sample_rate"></a> [sqs\_success\_feedback\_sample\_rate](#input\_sqs\_success\_feedback\_sample\_rate) | Role ARN for sqs endpoint delivery success | `string` | `null` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | If set, the full name of the SNS Topic, otherwise it will be set to the CSI | `string` | `null` | no |
| <a name="input_tracing_config"></a> [tracing\_config](#input\_tracing\_config) | Tracing mode of an Amazon SNS topic. Valid values: 'PassThrough', 'Active'. | `string` | `null` | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br>    local   = string<br>    account = optional(string, null) # Not used in this module<br>    global  = optional(string, null) # Not used in this module<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_feedback_config"></a> [feedback\_config](#output\_feedback\_config) | n/a |
| <a name="output_topic"></a> [topic](#output\_topic) | n/a |
| <a name="output_topic_policy"></a> [topic\_policy](#output\_topic\_policy) | n/a |
<!-- END_TF_DOCS -->