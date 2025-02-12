<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | Alias name for the KMS key (to be prefixed with alias/). Set to 'csi' to use the module's CSI alias naming convention | `string` | `"null"` | no |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | Whether to bypass the policy lockout safety check. Defaults to false. Only set to true if you are sure you want to do this. | `bool` | `false` | no |
| <a name="input_create_policies"></a> [create\_policies](#input\_create\_policies) | Whether to create Admin and User IAM policies for the KMS key. Defaults to true | `bool` | `true` | no |
| <a name="input_deletion_window"></a> [deletion\_window](#input\_deletion\_window) | KMS key deletion window in days | `number` | `7` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key (to be prefixed with CSI) | `string` | `null` | no |
| <a name="input_iam_delegation"></a> [iam\_delegation](#input\_iam\_delegation) | Whether to delegate administration of the key to the local account. Defaults to true | `bool` | `true` | no |
| <a name="input_key_policy_documents"></a> [key\_policy\_documents](#input\_key\_policy\_documents) | List of KMS key policy JSON documents | `list(string)` | `[]` | no |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_rotation"></a> [rotation](#input\_rotation) | Whether to enable key rotation. Defaults to true | `bool` | `true` | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_policy_arn"></a> [admin\_policy\_arn](#output\_admin\_policy\_arn) | n/a |
| <a name="output_admin_policy_json"></a> [admin\_policy\_json](#output\_admin\_policy\_json) | n/a |
| <a name="output_key_alias"></a> [key\_alias](#output\_key\_alias) | n/a |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | n/a |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | n/a |
| <a name="output_user_policy_arn"></a> [user\_policy\_arn](#output\_user\_policy\_arn) | n/a |
| <a name="output_user_policy_json"></a> [user\_policy\_json](#output\_user\_policy\_json) | n/a |
<!-- END_TF_DOCS -->
