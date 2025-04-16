
# Main API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = var.aws_api_gateway_rest_api_name
  description = "API Gateway para autenticação, geração de URLs pre-assinadas e integração com DynamoDB"
}

# Auth Resource
resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.auth.id
  http_method             = aws_api_gateway_method.auth_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  credentials             = aws_iam_role.api_gateway_invoke_lambda_role.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.auth_lambda_arn}/invocations"
}

# Presigned Resource
resource "aws_api_gateway_resource" "presigned" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "presigned"
}

resource "aws_api_gateway_method" "presigned_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.presigned.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "presigned_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.presigned.id
  http_method             = aws_api_gateway_method.presigned_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  credentials             = aws_iam_role.api_gateway_invoke_lambda_role.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.presigned_lambda_arn}/invocations"
}

# Files Resource for DynamoDB
resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "file_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "dynamodb_methods" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.file_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}


resource "aws_api_gateway_integration" "dynamodb_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.dynamodb_methods.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/GetItem"
  credentials             = aws_iam_role.api_gateway_dynamodb_role.arn

  request_templates = {
    "application/json" = <<EOF
      {
        "TableName": "${var.dynamodb_table_name}",
        "Key": {
          "id": { "S": "$input.params('id')" }
        }
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.dynamodb_methods.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.dynamodb_methods.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "$input.body"
  }

  depends_on = [aws_api_gateway_integration.dynamodb_integration]
}

# locals {
#   http_methods = ["GET", "POST", "PUT", "DELETE"]
#   dynamodb_actions = {
#     "GET"    = "GetItem"
#     "POST"   = "PutItem"
#     "PUT"    = "UpdateItem"
#     "DELETE" = "DeleteItem"
#   }
# }



# locals {
#   get_item_template = <<EOF
# {
#   "TableName": "${var.dynamodb_table_name}",
#   "Key": {
#     "id": { "S": "$input.params('id')" }
#   }
# }
# EOF

#   default_template = <<EOF
# {
#   "TableName": "${var.dynamodb_table_name}",
#   "Item": $input.json('$')
# }
# EOF
# }

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name            = var.aws_api_gateway_authorizer_name
  rest_api_id     = aws_api_gateway_rest_api.api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [
    "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${var.user_pool_id}",
    "arn:aws:cognito-idp:us-east-1:913524932573:userpool/us-east-1_7gyJi8M1a"
  ]
  identity_source = "method.request.header.Authorization"
}

# Deployment and Stage
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.auth_integration,
    aws_api_gateway_integration.presigned_integration,
    aws_api_gateway_integration.dynamodb_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Criar o CloudWatch Log Group para armazenar os logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${var.stage_name}"
  retention_in_days = 7 # Retenção dos logs por 7 dias
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name

  depends_on = [aws_cloudwatch_log_group.api_logs]
}
