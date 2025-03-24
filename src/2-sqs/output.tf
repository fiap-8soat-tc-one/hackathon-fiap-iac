output "upload_queue_id" {
  value = aws_sqs_queue.upload_queue.id
}

output "upload_queue_url" {
  value = aws_sqs_queue.upload_queue.url
}

output "notification_queue_id" {
  value = aws_sqs_queue.notification_queue.id
}

output "notification_queue_url" {
  value = aws_sqs_queue.notification_queue.url
}
