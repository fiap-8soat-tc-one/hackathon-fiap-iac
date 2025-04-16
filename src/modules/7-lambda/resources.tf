resource "aws_lambda_function" "presigned_lambda" {
  function_name = "presigned_lambda"
  package_type  = "Image"
  image_uri     = "${var.presigned_lambda_repo}:latest"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout = 60
  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.user_pool_id
      COGNITO_CLIENT_ID    = var.client_id
      AWS_JAVA_V1_PRINT_LOCATION = "true"
      AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT  = "true"
    }
  }
}

resource "aws_lambda_function" "auth_lambda" {
  function_name = "auth_lambda"
  package_type  = "Image"
  image_uri     = "${var.auth_lambda_repo}:latest"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout = 60
  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.user_pool_id
      COGNITO_CLIENT_ID    = var.client_id
      AWS_JAVA_V1_PRINT_LOCATION = "true"
      AWS_JAVA_V1_DISABLE_DEPRECATION_ANNOUNCEMENT  = "true"
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Permissões para Lambdas de acesso ao S3 e Cognito"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
        {
          "Action": "s3:PutObject",
          "Effect": "Allow",
          "Resource": "arn:aws:s3:::*/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "cognito-idp:AdminInitiateAuth",
            "cognito-idp:AdminRespondToAuthChallenge"
          ],
          "Resource": "arn:aws:cognito-idp:us-east-1:913524932573:userpool/us-east-1_7gyJi8M1a"
        },
        {
          "Resource": "arn:aws:dynamodb:us-east-1:913524932573:table/fiap-hackaton-uploads",
          "Effect": "Allow",
          "Action": [
            "dynamodb:*"
          ]
        },
        {
        "Effect": "Allow",
        "Action": [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        "Resource": [
          "*"
        ]
      },
        {
          "Effect": "Allow",
          "Action": [
            "xray:PutTelemetryRecords",
            "xray:PutTraceSegments"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:us-east-1:913524932573:*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:us-east-1:913524932573:log-group:/aws/lambda/auth_lambda:*",
            "arn:aws:logs:us-east-1:913524932573:log-group:/aws/lambda/presigned_lambda:*"
          ]
        }
      ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}