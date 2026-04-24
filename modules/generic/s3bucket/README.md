<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [terraform_data.completion](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerate_configuration"></a> [accelerate\_configuration](#input\_accelerate\_configuration) | The accelerate configuration of the bucket. true == Enabled | `bool` | `false` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | Canned ACL to set on the bucket. Only used if ownership is not set to BucketOwnerEnforced | `string` | `null` | no |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Boolean to toggle bucket key enablement | `bool` | `true` | no |
| <a name="input_bucket_logging_target"></a> [bucket\_logging\_target](#input\_bucket\_logging\_target) | Map of S3 bucket access logging target properties | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The variable encapsulating the name of this bucket | `string` | `null` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | A set of CORS rules to apply to the bucket | <pre>set(object({<br/>    allowed_headers = optional(list(string))<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    expose_headers  = optional(list(string), [])<br/>    id              = optional(string, null)<br/>    max_age_seconds = optional(number, 0)<br/>  }))</pre> | `[]` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | Legacy compatibility input for callers that still provide an expected bucket owner.<br/><br/>The AWS provider has deprecated expected\_bucket\_owner on the managed S3 bucket<br/>subresources used by this module, so this value is currently ignored. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Boolean to toggle force destroy of bucket. Defaults to true; should be changed in exceptional circumstances | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of default encryption KMS key for this bucket. If omitted, will use AES256 | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Object representing the lifecycle rules of the bucket | <pre>object({<br/>    prefix = string<br/><br/>    noncurrent_version_transition = optional(list(object({<br/>      days          = string<br/>      storage_class = string<br/>    })), [])<br/><br/>    transition = optional(list(object({<br/>      days          = string<br/>      storage_class = string<br/>    })), [])<br/><br/>    noncurrent_version_expiration = optional(object({<br/>      days = string<br/>    }), { days = "-1" })<br/><br/>    expiration = optional(object({<br/>      days = string<br/>    }), { days = "-1" })<br/>  })</pre> | `null` | no |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Ownership of objects written to the bucket | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_policy_documents"></a> [policy\_documents](#input\_policy\_documents) | A list of JSON policies to use to build the bucket policy | `list(string)` | `[]` | no |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Whether to prevent the bucket's destruction with a lifecycle rule | `bool` | `false` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Object representing the public access rules of the bucket | <pre>object({<br/>    block_public_acls       = bool<br/>    block_public_policy     = bool<br/>    ignore_public_acls      = bool<br/>    restrict_public_buckets = bool<br/>  })</pre> | <pre>{<br/>  "block_public_acls": true,<br/>  "block_public_policy": true,<br/>  "ignore_public_acls": true,<br/>  "restrict_public_buckets": true<br/>}</pre> | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Toggle for versioning the bucket. Defaults to true | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acl"></a> [acl](#output\_acl) | n/a |
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | n/a |
| <a name="output_bucket_cors_configuration"></a> [bucket\_cors\_configuration](#output\_bucket\_cors\_configuration) | n/a |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | n/a |
| <a name="output_bucket_ownership_controls"></a> [bucket\_ownership\_controls](#output\_bucket\_ownership\_controls) | Legacy |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | n/a |
| <a name="output_completion"></a> [completion](#output\_completion) | n/a |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_lifecycle_configuration_id"></a> [lifecycle\_configuration\_id](#output\_lifecycle\_configuration\_id) | n/a |
| <a name="output_logging"></a> [logging](#output\_logging) | n/a |
| <a name="output_ownership_controls"></a> [ownership\_controls](#output\_ownership\_controls) | n/a |
| <a name="output_policy"></a> [policy](#output\_policy) | n/a |
| <a name="output_public_access_block"></a> [public\_access\_block](#output\_public\_access\_block) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_server_side_encryption_configuration_id"></a> [server\_side\_encryption\_configuration\_id](#output\_server\_side\_encryption\_configuration\_id) | n/a |
| <a name="output_versioning"></a> [versioning](#output\_versioning) | n/a |
<!-- END_TF_DOCS -->
