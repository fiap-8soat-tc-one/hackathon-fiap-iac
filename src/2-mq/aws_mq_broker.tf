
resource "aws_mq_broker" "rabbitmq_hackaton" {
  broker_name                = var.broker_name
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  auto_minor_version_upgrade = true

  publicly_accessible = true 

  user {
    username = var.rabbitmq_user
    password = var.rabbitmq_password
  }

  subnet_ids      = [data.terraform_remote_state.vpc.outputs.public_subnet_a]
}