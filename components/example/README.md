<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.79.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.79.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sns_something"></a> [sns\_something](#module\_sns\_something) | ../../modules/generic/sns | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS Account ID (numeric) | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Suffix for) the name for the name of the S3 bucket | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment variables are being inherited from | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The group variables are being inherited from (often synonmous with account short-name) | `string` | `""` | no |
| <a name="input_project"></a> [project](#input\_project) | The tfscaffold project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_tfscaffold_bucket_prefix"></a> [tfscaffold\_bucket\_prefix](#input\_tfscaffold\_bucket\_prefix) | The tfscaffold bucket prefix (mostly for constructing remote states) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | n/a |
| <a name="output_something_sns_topic_arn"></a> [something\_sns\_topic\_arn](#output\_something\_sns\_topic\_arn) | n/a |
<!-- END_TF_DOCS -->