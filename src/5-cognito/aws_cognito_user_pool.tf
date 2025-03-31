resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false
  }

  auto_verified_attributes = ["email"]
}


resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                = var.user_pool_client
  user_pool_id        = aws_cognito_user_pool.user_pool.id
  generate_secret     = false
  allowed_oauth_flows = ["client_credentials", "password"]
  allowed_oauth_scopes = ["openid", "aws.cognito.signin.user.admin"]
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user" "upload_user" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = "fiap@fiap.com"
  attributes = {
    email_verified = "true"
    email          = "fiap@fiap.com"
  }
  password = "SecurePass123!"
}
