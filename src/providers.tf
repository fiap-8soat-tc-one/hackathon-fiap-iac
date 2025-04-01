terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "stg"
      Owner       = "t32"
      Managed-by  = "Terraform"
      Name        = "fiap-hackaton"
    }
  }
}