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
