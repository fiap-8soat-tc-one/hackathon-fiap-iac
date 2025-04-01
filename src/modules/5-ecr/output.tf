output  "presigned_lambda_repo" {
  value = aws_ecr_repository.presigned_lambda_repo.repository_url
}

output  "auth_lambda_repo" {
  value = aws_ecr_repository.auth_lambda_repo.repository_url
}

output "file_engine_repo" {
  value = aws_ecr_repository.file_engine_repo.repository_url
}

output "notification_repo" {
  value = aws_ecr_repository.notification_repo.repository_url
}