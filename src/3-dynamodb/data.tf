# Get AWS account and region information
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "vpc/terraform.state"
    region = "us-east-1"
  }
}
