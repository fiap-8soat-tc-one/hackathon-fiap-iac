# Get AWS account and region information
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "ecr/terraform.state"
    region = "us-east-1"
  }
}