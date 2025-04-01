
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
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambda.outputs.auth_lambda_arn}/invocations"
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
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambda.outputs.presigned_lambda_arn}/invocations"
}

# Files Resource for DynamoDB
resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_method" "dynamodb_methods" {
  for_each      = toset(["GET", "POST", "PUT", "DELETE"])
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = each.key
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "dynamodb_integration" {
  for_each                = aws_api_gateway_method.dynamodb_methods
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.files.id
  http_method             = each.key
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/${each.key}Item"
  credentials             = aws_iam_role.api_gateway_dynamodb_role.arn

  request_templates = {
    "application/json" = each.key == "GET" ? local.get_item_template : local.default_template
  }
}

locals {
  get_item_template = <<EOF
{
  "TableName": "${data.terraform_remote_state.dynadb.outputs.table_name}",
  "Key": {
    "id": { "S": "$input.params('id')" }
  }
}
EOF

  default_template = <<EOF
{
  "TableName": "${data.terraform_remote_state.dynadb.outputs.table_name}",
  "Item": $input.json('$')
}
EOF
}

resource "aws_iam_role" "api_gateway_dynamodb_role" {
  name = "api-gateway-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for DynamoDB access
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "dynamodb-policy"
  role = aws_iam_role.api_gateway_dynamodb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = data.terraform_remote_state.dynadb.outputs.table_arn
      }
    ]
  })
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = var.aws_api_gateway_authorizer_name
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = ["arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${data.terraform_remote_state.cognito.outputs.user_pool_id}"]
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

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "stg"
}