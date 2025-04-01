variable "user_pool_name" {
  default = "users-pool"
  type = string
}

variable "user_pool_client" {
  default = "users-pool-app-client"
  type = string
}

variable "cognito_user_email" {
  default = "fiap@fiap.com"
  type = string
}

variable "cognito_user_password" {
  default = "@@Fiap123456!!"
  type = string
}