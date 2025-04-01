resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false
  }

  auto_verified_attributes = ["email"]

    password_policy {
    minimum_length                   = 8
    require_lowercase               = true
    require_uppercase               = true
    require_numbers                 = true
    require_symbols                 = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  username_configuration {
    case_sensitive = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}


resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                                 = var.user_pool_client
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
  
  access_token_validity  = 1  
  id_token_validity     = 1  
  refresh_token_validity = 30 
}

resource "aws_cognito_user" "upload_user" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.cognito_user_email
  attributes = {
    email_verified = "true"
    email          = var.cognito_user_email
  }
  password = var.cognito_user_password
}
