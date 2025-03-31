resource "aws_ecr_repository" "presigned_lambda_repo" {
  name = "presigned-lambda-repo"
}

resource "aws_ecr_repository" "auth_lambda_repo" {
  name = "auth-lambda-repo"
}

resource "aws_lambda_function" "presigned_lambda" {
  function_name = "presigned_lambda"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.presigned_lambda_repo.repository_url}:latest"
  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_lambda_function" "auth_lambda" {
  function_name = "auth_lambda"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.auth_lambda_repo.repository_url}:latest"
  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
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
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*/*"
      },
      {
        Action   = "cognito-idp:AdminInitiateAuth"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}