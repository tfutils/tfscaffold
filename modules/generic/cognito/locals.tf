locals {
  # bools
  custom_domain = var.custom_domain != null
  saml_idp      = var.saml_idp != null

  # UI Customisation
  identity_provider_name = coalesce(try(var.saml_idp["ui_customisation"]["name"], null), local.unique_id)

  # Cognito User Pool
  user_pool_client               = local.saml_idp ? aws_cognito_user_pool_client.saml[0] : aws_cognito_user_pool_client.cognito[0]
  user_pool_client_callback_urls = [ "https://${var.app_fqdn}/oauth2/idpresponse" ]
  user_pool_client_logout_urls   = var.logout_urls_are_callback_urls ? local.user_pool_client_callback_urls : var.logout_urls
  user_pool_client_secret        = local.saml_idp ? aws_cognito_user_pool_client.saml[0].client_secret : aws_cognito_user_pool_client.cognito[0].client_secret
  user_pool_domain               = local.custom_domain ? var.custom_domain["fqdn"] : "${local.user_pool_domain_prefix}.auth.${local.region}.amazoncognito.com"
  user_pool_domain_prefix        = coalesce(var.user_pool_domain_prefix, local.unique_id)
}
