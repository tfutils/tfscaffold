resource "aws_cognito_user_pool_ui_customization" "saml" {
  count = local.saml_idp && var.saml_idp["ui_customisation"] != null ? 1 : 0

  client_id = aws_cognito_user_pool_client.saml[0].id

  css = var.saml_idp["ui_customisation"]["css"]

  image_file = (
    var.saml_idp["ui_customisation"]["image"] == null ? null :
    var.saml_idp["ui_customisation"]["image"]["base64"] != null ? var.saml_idp["ui_customisation"]["image"]["base64"] :
    filebase64(var.saml_idp["ui_customisation"]["image"]["file"])
  )

  # Refer to the aws_cognito_user_pool_domain resource's
  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = local.custom_domain ? aws_cognito_user_pool_domain.custom[0].user_pool_id : aws_cognito_user_pool_domain.prefix[0].user_pool_id

  depends_on = [
    aws_cognito_user_pool.main,
    aws_cognito_user_pool_domain.prefix,
    aws_cognito_user_pool_domain.custom,
  ]
}
