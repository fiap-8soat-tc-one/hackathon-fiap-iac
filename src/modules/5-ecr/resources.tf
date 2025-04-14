resource "aws_ecr_repository" "presigned_lambda_repo" {
  name = "presigned-lambda-repo"
}

resource "aws_ecr_repository" "auth_lambda_repo" {
  name = "auth-lambda-repo"
}

resource "aws_ecr_repository" "file_engine_repo" {
  name = "file-engine-repo"
}

resource "aws_ecr_repository" "notification_repo" {
  name = "notification-repo"
}
