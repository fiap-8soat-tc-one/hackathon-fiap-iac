variable "aws_region" {
  default = "us-east-1"
}

variable "broker_name" {
  default = "rabbitmq-broker"
}

variable "rabbitmq_user" {
  default = "admin"
}

variable "rabbitmq_password" {
  description = "Senha do RabbitMQ (mín. 12 caracteres)"
  default     = "HackatonFiapAdm123!!"
}