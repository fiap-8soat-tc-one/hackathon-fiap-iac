variable "dynamodb_table_name" {
  default = "fiap-hackaton-uploads"
}
variable "dynamo_policy_name" {
  default = "DynamoDbPolicyAllowAccess"
}

variable "cidr_block" { 
  type = string
}