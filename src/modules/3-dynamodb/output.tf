output "table_name" {
  value = aws_dynamodb_table.uploads.name
}

output "table_arn" {
  value = aws_dynamodb_table.uploads.arn
}

output "access_policy_arn" {
  value = aws_iam_policy.dynamodb_access.arn
}
