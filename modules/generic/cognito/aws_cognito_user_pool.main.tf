resource "aws_cognito_user_pool" "main" {
  name = local.unique_id

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    dynamic "recovery_mechanism" {
      for_each = var.sms_enabled ? [1] : []

      content {
        name     = "verified_phone_number"
        priority = 2
      }
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

  software_token_mfa_configuration {
    enabled = true
  }

  dynamic "sms_configuration" {
    for_each = var.sms_enabled ? [1] : []

    content {
      external_id    = "${local.unique_id}-user-pool"
      sns_caller_arn = aws_iam_role.cognito_user_pool_sms[0].arn
    }
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
