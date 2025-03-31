
resource "aws_api_gateway_rest_api" "api" {
  name        = var.aws_api_gateway_rest_api_name
  description = "API Gateway para autenticação, geração de URLs pre-assinadas e integração com DynamoDB"
}

# API Gateway para presigned_lambda
resource "aws_api_gateway_rest_api" "presigned_api" {
  name        = "presigned_api"
  description = "API Gateway para a presigned Lambda"
}

resource "aws_api_gateway_resource" "presigned_lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.presigned_api.id
  parent_id   = aws_api_gateway_rest_api.presigned_api.root_resource_id
  path_part   = "presigned"
}

resource "aws_api_gateway_method" "presigned_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.presigned_api.id
  resource_id   = aws_api_gateway_resource.presigned_lambda_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "presigned_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.presigned_api.id
  resource_id = aws_api_gateway_resource.presigned_lambda_resource.id
  http_method = aws_api_gateway_method.presigned_lambda_method.http_method
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${terraform_remote_state.lambda.outputs.presigned_lambda_arn}/invocations"
}

# API Gateway para auth_lambda (se necessário)
resource "aws_api_gateway_rest_api" "auth_api" {
  name        = "auth_api"
  description = "API Gateway para a auth Lambda"
}

resource "aws_api_gateway_resource" "auth_lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_rest_api.auth_api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.auth_lambda_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  resource_id = aws_api_gateway_resource.auth_lambda_resource.id
  http_method = aws_api_gateway_method.auth_lambda_method.http_method
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${terraform_remote_state.lambda.outputs.auth_lambda_arn}/invocations"
}

# Recurso /files para integração com DynamoDB
resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_method" "dynamodb_methods" {
  for_each     = toset(["GET", "POST", "PUT", "DELETE"])
  rest_api_id  = aws_api_gateway_rest_api.api.id
  resource_id  = aws_api_gateway_resource.files.id
  http_method  = each.key
  authorization = var.aws_api_gateway_authorizer_type
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "dynamodb_integration" {
  for_each     = aws_api_gateway_method.dynamodb_methods
  rest_api_id  = aws_api_gateway_rest_api.api.id
  resource_id  = aws_api_gateway_resource.files.id
  http_method  = each.key
  integration_http_method = "POST"
  type        = "AWS"
  uri         = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/${each.key}Item"

  request_templates = {
    "application/json" = <<EOF
{
  "TableName": "${terraform_remote_state.dynadb.outputs.table_name}",
  "Key": {
    "id": { "S": "$input.params('id')" }
  }
}
EOF
  }
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = var.aws_api_gateway_authorizer_name
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = var.aws_api_gateway_authorizer_type
  provider_arns = ["arn:aws:cognito-idp:${var.aws_region}:${data.aws_caller_identity.current.account_id}:userpool/${terraform_remote_state.cognito.outputs.user_pool_id}"]
}

# Deploy da API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.auth_lambda_integration, aws_api_gateway_integration.presigned_lambda_integration, aws_api_gateway_integration.dynamodb_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "stg"
}


