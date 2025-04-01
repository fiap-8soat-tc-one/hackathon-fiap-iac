terraform {
  backend "s3" {
    bucket = "bucket-tfst-fiap-hackaton-t32"
    key    = "hackathon/terraform.tfstate"
    region = "us-east-1"
  }
}