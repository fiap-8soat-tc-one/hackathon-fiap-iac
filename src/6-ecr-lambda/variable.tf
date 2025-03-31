variable "aws_api_gateway_authorizer_name" {
  description = "Nome do authorizer do API Gateway"
  type        = string
  default     = "cognito-authorizer"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_api_gateway_authorizer_type" {
  description = "ID do authorizer do API Gateway"
  type        = string
  default     = "COGNITO_USER_POOLS"
}

variable "aws_api_gateway_rest_api_name" {
  description = "Nome do API Gateway"
  type        = string
  default     = "fiap-hackaton-api"
}