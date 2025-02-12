resource "aws_cognito_user_pool_client" "saml" {
  count = local.saml_idp ? 1 : 0

  name = "${local.unique_id}-saml"

  user_pool_id = aws_cognito_user_pool.main.id

  access_token_validity = var.access_token_validity["value"]

  token_validity_units {
    access_token = var.access_token_validity["units"]
  }

  allowed_oauth_flows = [
    "code",
    "implicit",
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = local.user_pool_client_callback_urls
  explicit_auth_flows                  = var.explicit_auth_flows
  generate_secret                      = true
  logout_urls                          = local.user_pool_client_logout_urls

  supported_identity_providers = [
    aws_cognito_identity_provider.saml[0].provider_name,
  ]
}
