output "invoke_url" {
  value = concat(aws_api_gateway_deployment.deployment.invoke_url, "/", aws_api_gateway_stage.prod_stage.stage_name)
}
