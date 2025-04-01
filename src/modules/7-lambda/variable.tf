variable "aws_api_gateway_authorizer_name" {
  type        = string
  default     = "cognito-authorizer"
}

variable "aws_api_gateway_authorizer_type" {
  type        = string
  default     = "COGNITO_USER_POOLS"
}

variable "aws_api_gateway_rest_api_name" {
  type        = string
  default     = "fiap-hackaton-api"
}

variable  "presigned_lambda_repo" {
  type        = string
}

variable  "auth_lambda_repo" {
  type        = string
}
