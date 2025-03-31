output "presigned_lambda_arn" {
  value = aws_lambda_function.presigned_lambda.arn
}

output "auth_lambda_arn" {
  value = aws_lambda_function.auth_lambda.arn
}