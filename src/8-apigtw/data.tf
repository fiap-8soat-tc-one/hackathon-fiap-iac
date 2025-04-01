# Get AWS account and region information
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "dynadb" {
  backend = "s3"

  config = {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "dynadb/terraform.state"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "cognito" {
  backend = "s3"

  config = {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "cognito/terraform.state"
    region = "us-east-1"
  }
}


data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "lambda/terraform.state"
    region = "us-east-1"
  }
}

