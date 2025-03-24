variable "aws_region" {
  default = "us-east-1"
}

variable "sqs_upload_queue_name" {
  default = "upload-event-queue"
}

variable "sqs_notification_queue_name" {
  default = "notification-event-queue"
}

variable "s3_bucket_name" {
  default = "bucket-fiap-hackaton-t32-files"
}
