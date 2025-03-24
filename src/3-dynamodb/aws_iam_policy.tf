resource "aws_iam_policy" "dynamodb_access" {
  name = var.dynamo_policy_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowAccessFromMyVPC",
        Effect : "Allow",
        Action = "dynamodb:*",
        Resource : aws_dynamodb_table.uploads.arn,
        Condition : {
          IpAddress : {
            "aws:SourceIp" : data.terraform_remote_state.vpc.outputs.cidr_block
          }
        }
      },
      {
        Sid : "AllowInternetAccessForTesting",
        Effect : "Allow",
        Action = "dynamodb:*",
        Resource : aws_dynamodb_table.uploads.arn,
        Condition : {
          IpAddress : {
            "aws:SourceIp" : "0.0.0.0/0"
          }
        }
      }
    ]
  })
}
