resource "aws_cognito_user_pool_client" "cognito" {
  count = local.saml_idp ? 0 : 1

  name = "${local.unique_id}-cognito"

  user_pool_id = aws_cognito_user_pool.main.id

  access_token_validity = var.access_token_validity["value"]

  token_validity_units {
    access_token = var.access_token_validity["units"]
  }

  allowed_oauth_flows = [
    "code",
  ]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = local.user_pool_client_callback_urls
  explicit_auth_flows                  = var.explicit_auth_flows
  generate_secret                      = var.generate_secret
  logout_urls                          = local.user_pool_client_logout_urls

  supported_identity_providers = [
    "COGNITO",
  ]
}
