output "user_pool" { 
  value = {
    arn    = aws_cognito_user_pool.main.arn
    id     = aws_cognito_user_pool.main.id
    domain = local.user_pool_domain
  } 
}

output "user_pool_client" {
  description = "Client User Pool Client Secret"

  value = {
    id            = local.user_pool_client["id"]
    secret        = sensitive(local.user_pool_client_secret)
    callback_url  = tolist(local.user_pool_client["callback_urls"])[0]
    callback_urls = local.user_pool_client["callback_urls"]
    logout_url    = tolist(local.user_pool_client["logout_urls"])[0]
    logout_urls   = local.user_pool_client["logout_urls"]
  }
}

##
# SAML
##

output "saml_parameters" {
  description = "SAML Parameters"

  value = {
    "Assertion Consumer Service URL (Reply URL)" = "https://${local.user_pool_domain}/saml2/idpresponse"
    "Audience URI (Identifier / Entity ID)"      = "urn:amazon:cognito:sp:${aws_cognito_user_pool.main.id}"
    "Sign on URL"                                = tolist(local.user_pool_client["callback_urls"])[0]
    "Logout URL"                                 = tolist(local.user_pool_client["logout_urls"])[0]
  }
}
