resource "aws_dynamodb_table" "uploads" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "status_upload"
    type = "S"
  }

  attribute {
    name = "url_download"
    type = "S"
  }

  attribute {
    name = "data_criacao"
    type = "S"
  }

  global_secondary_index {
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "url_download-index"
    hash_key        = "url_download"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "status_upload"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "data-criacao-index"
    hash_key        = "data_criacao"
    projection_type = "ALL"
  }
}

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
            "aws:SourceIp" : var.cidr_block
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

