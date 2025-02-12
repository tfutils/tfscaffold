resource "aws_cognito_user_pool" "main" {
  name = local.unique_id

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_email"
      priority = 2
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = [
    "email",
  ]

  mfa_configuration = "OPTIONAL"

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  sms_configuration {
    external_id    = "${local.unique_id}-user-pool"
    sns_caller_arn = aws_iam_role.cognito_user_pool_sms.arn
  }

  username_attributes = [
    "email",
  ]

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "The verification code to your new account is {####}"
    email_subject        = "Verify your new account"
    sms_message          = "The verification code to your new account is {####}"
  }

  tags = local.default_tags
}
