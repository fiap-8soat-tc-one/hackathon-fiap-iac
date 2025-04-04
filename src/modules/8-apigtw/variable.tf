variable "aws_api_gateway_authorizer_name" {
  type    = string
  default = "cognito-authorizer"
}

variable "aws_api_gateway_authorizer_type" {
  type    = string
  default = "COGNITO_USER_POOLS"
}

variable "aws_api_gateway_rest_api_name" {
  type    = string
  default = "fiap-hackaton-api"
}

variable "stage_name" {
  type    = string
  default = "dev"
}

variable "presigned_lambda_arn" {
  type = string
}

variable "auth_lambda_arn" {
  type = string
}

variable "user_pool_id" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}
