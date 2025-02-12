resource "aws_cognito_identity_provider" "saml" {
  count = local.saml_idp ? 1 : 0

  user_pool_id = aws_cognito_user_pool.main.id
  
  provider_name = local.identity_provider_name
  provider_type = "SAML"

  attribute_mapping = {
    email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  }

  provider_details = {
    MetadataFile = var.saml_idp["sso_metadata"]["content"]
    MetadataURL  = var.saml_idp["sso_metadata"]["url"]
  }

  # ActiveEncryptionCertificate, SLORedirectBindingURI and SSORedirectBindingURI are only populated from MetadataURL
  lifecycle {
    ignore_changes = [
      provider_details["ActiveEncryptionCertificate"],
      provider_details["SLORedirectBindingURI"],
      provider_details["SSORedirectBindingURI"],
    ]
  }
}
