<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.85.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_identity_provider.saml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_user_pool.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_client.saml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_user_pool_domain.prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_user_pool_ui_customization.saml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_ui_customization) | resource |
| [aws_iam_role.cognito_user_pool_sms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cognito_user_pool_sms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.alias_cognito_user_pool_domain_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_iam_policy_document.cognito_user_pool_admin_get_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito_user_pool_assumerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito_user_pool_manage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cognito_user_pool_read_create_entities](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_publish_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_token_validity"></a> [access\_token\_validity](#input\_access\_token\_validity) | Access Token Validity | <pre>object({<br/>    value = optional(number, 480)<br/>    units = optional(string, "minutes")<br/>  })</pre> | <pre>{<br/>  "units": "minutes",<br/>  "validity": 480<br/>}</pre> | no |
| <a name="input_allowed_oauth_scopes"></a> [allowed\_oauth\_scopes](#input\_allowed\_oauth\_scopes) | Allowed OAuth Scopes for Cognito | `list(string)` | <pre>[<br/>  "openid",<br/>  "email",<br/>  "profile"<br/>]</pre> | no |
| <a name="input_app_fqdn"></a> [app\_fqdn](#input\_app\_fqdn) | Fully Qualified Domain Name for the App protected by Cognito | `string` | n/a | yes |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | Callback URLs for Cognito | `list(string)` | `[]` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Optional FQDN & Route53 Public Hosted Zone ID for a custom Cognito User Pool Domain | <pre>object({<br/>    cloudfront_acm_certificate_arn = string<br/>    fqdn                           = string<br/>    route53_public_hosted_zone_id  = string<br/>  })</pre> | `null` | no |
| <a name="input_explicit_auth_flows"></a> [explicit\_auth\_flows](#input\_explicit\_auth\_flows) | Explicit Auth Flows for Cognito | `list(string)` | <pre>[<br/>  "ALLOW_USER_PASSWORD_AUTH",<br/>  "ALLOW_USER_SRP_AUTH",<br/>  "ALLOW_REFRESH_TOKEN_AUTH"<br/>]</pre> | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | Logout URLs for Cognito if logout\_urls\_are\_callback\_urls is false | `list(string)` | `[]` | no |
| <a name="input_logout_urls_are_callback_urls"></a> [logout\_urls\_are\_callback\_urls](#input\_logout\_urls\_are\_callback\_urls) | Whether the Logout URLs are the same as the Callback URLs | `bool` | `true` | no |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_saml_idp"></a> [saml\_idp](#input\_saml\_idp) | n/a | <pre>object({<br/>    sso_metadata = object({<br/>      url     = optional(string, null) # "https://login.microsoftonline.com/<tenant_id>/federationmetadata/2007-06/federationmetadata.xml?appid=<app_id>"<br/>      content = optional(string, null) # "<xml>...</xml>"<br/>    })<br/><br/>    ui_customisation = object({<br/>      css = optional(string, ".label-customizable {font-weight: 400;}")<br/><br/>      image = optional(object({<br/>        base64 = optional(string, null)<br/>        file   = optional(string, null)<br/>      }), null)<br/><br/>      name = optional(string, null)<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_user_pool_domain_prefix"></a> [user\_pool\_domain\_prefix](#input\_user\_pool\_domain\_prefix) | Cognito User Pool Domain Prefix if not using a custom domain. Defaults to local.unique\_id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_saml_parameters"></a> [saml\_parameters](#output\_saml\_parameters) | SAML Parameters |
| <a name="output_user_pool"></a> [user\_pool](#output\_user\_pool) | n/a |
| <a name="output_user_pool_client"></a> [user\_pool\_client](#output\_user\_pool\_client) | Client User Pool Client Secret |
<!-- END_TF_DOCS -->