resource "aws_iam_role" "api_gateway_invoke_lambda_role" {
  name = "apigateway-invoke-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "invoke_lambda_policy" {
  name = "invoke-lambda-from-apigateway"
  role = aws_iam_role.api_gateway_invoke_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "${var.auth_lambda_arn}",
          "${var.presigned_lambda_arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "api_gateway_dynamodb_role" {
  name = "apigateway-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "apigateway_policy" {
  name = "dynamodb-get-policy"
  role = aws_iam_role.api_gateway_dynamodb_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
        ],
        Effect   = "Allow",
        Resource = "${var.dynamodb_table_arn}"
      }
    ]
  })
}

