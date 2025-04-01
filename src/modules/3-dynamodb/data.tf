# Get AWS account and region information
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
