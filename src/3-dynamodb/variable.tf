variable "aws_region" {
  default = "us-east-1"
}

variable "dynamodb_table_name" {
  default = "fiap-hackaton-uploads"
}
variable "dynamo_policy_name" {
  default = "DynamoDbPolicyAllowAccess"
}