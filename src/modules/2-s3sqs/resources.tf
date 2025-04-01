resource "aws_s3_bucket" "upload_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_notification" "s3_to_sqs" {
  bucket = aws_s3_bucket.upload_bucket.id
  queue {
    queue_arn = aws_sqs_queue.upload_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sqs_queue_policy.allow_sqs_upload_queue_policy]
}

resource "aws_sqs_queue" "upload_queue" {
  name = var.sqs_upload_queue_name
}

resource "aws_sqs_queue" "notification_queue" {
  name = var.sqs_notification_queue_name
}

resource "aws_sqs_queue_policy" "allow_sqs_upload_queue_policy" {
  queue_url = aws_sqs_queue.upload_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Allow-S3-To-SendMessage",
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.upload_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.upload_bucket.arn
          }
        }
      },
      {
        Sid       = "AllowVPCResources",
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:*",
        Resource  = aws_sqs_queue.upload_queue.arn,
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.cidr_block
          }
        }
      },
      {
        Sid       = "AllowInternetAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:*",
        Resource  = aws_sqs_queue.upload_queue.arn,
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "0.0.0.0/0"
          }
        }
      }
    ]
  })

}

resource "aws_sqs_queue_policy" "allow_sqs_notification_queue_policy" {
  queue_url = aws_sqs_queue.notification_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowVPCResources",
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:*",
        Resource  = aws_sqs_queue.notification_queue.arn,
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.cidr_block
          }
        }
      },
      {
        Sid       = "AllowInternetAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:*",
        Resource  = aws_sqs_queue.notification_queue.arn,
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "0.0.0.0/0"
          }
        }
      }
    ]
  })

}

