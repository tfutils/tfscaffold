##
# Generic tfscaffold Module Variables
##

variable "aws" {
  type = object({
    account_id   = string
    default_tags = optional(map(string), {})
    partition    = optional(string, "aws")
    region       = string
    url_suffix   = optional(string, "amazonaws.com")
  })
}

variable "module_parents" {
  type        = list(string)
  description = "List of parent module names"
  default     = []
}

variable "unique_ids" {
  type = object({
    # All marked as optional for consistency of code.
    # Whether each is optional depends on the module implementation.
    local   = optional(string, null)
    account = optional(string, null)
    global  = optional(string, null)
  })
}

##
# Variable specific to the module
##

variable "app_fqdn" {
  type        = string
  description = "Fully Qualified Domain Name for the App protected by Cognito"
}

variable "custom_domain" {
  type = object({
    cloudfront_acm_certificate_arn = string
    fqdn                           = string
    route53_public_hosted_zone_id  = string
  })

  description = "Optional FQDN & Route53 Public Hosted Zone ID for a custom Cognito User Pool Domain"
  default     = null
}

variable "user_pool_domain_prefix" {
  type        = string
  description = "Cognito User Pool Domain Prefix if not using a custom domain. Defaults to local.unique_id"
  default     = null
}

variable "saml_idp" {
  type = object({
    sso_metadata = object({
      url     = optional(string, null) # "https://login.microsoftonline.com/<tenant_id>/federationmetadata/2007-06/federationmetadata.xml?appid=<app_id>"
      content = optional(string, null) # "<xml>...</xml>"
    })

    ui_customisation = object({
      css = optional(string, ".label-customizable {font-weight: 400;}")

      image = optional(object({
        base64 = optional(string, null)
        file   = optional(string, null)
      }), null)

      name = optional(string, null)
    })
  })

  validation {
    condition = (
      var.saml_idp == null ? true :
      var.saml_idp["sso_metadata"]["url"] != var.saml_idp["sso_metadata"]["content"]
    )

    error_message = "Either SAML SSO Metadata URL or SAML SSO Metadata Content must be set when using a SAML IdP, but not both"
  }

  validation {
    condition = (
      var.saml_idp["ui_customisation"] == null ? true :
      var.saml_idp["ui_customisation"]["image"] == null ? true :
      var.saml_idp["ui_customisation"]["image"]["base64"] != var.saml_idp["ui_customisation"]["image"]["file"]
    )

    error_message = "When specifying a custom image for the SAML IdP UI Customisation, either the base64 or file path must be set, but not both"
  }

  default = null
}

# AWS Cognito

variable "access_token_validity" {
  type = object({
    value = optional(number, 480)
    units = optional(string, "minutes")
  })

  description = "Access Token Validity"

  default = {
    value = 480
    units = "minutes"
  }
}

variable "allowed_oauth_scopes" {
  type        = list(string)
  description = "Allowed OAuth Scopes for Cognito"

  default = [
    "openid",
    "email",
    "profile",
  ]
}

variable "explicit_auth_flows" {
  type        = list(string)
  description = "Explicit Auth Flows for Cognito"

  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

variable "logout_urls_are_callback_urls" {
  type        = bool
  description = "Whether the Logout URLs are the same as the Callback URLs"
  default     = true
}

variable "callback_urls" {
  type        = list(string)
  description = "Callback URLs for Cognito"
  default     = []
}

variable "logout_urls" {
  type        = list(string)
  description = "Logout URLs for Cognito if logout_urls_are_callback_urls is false"
  default     = []
}
