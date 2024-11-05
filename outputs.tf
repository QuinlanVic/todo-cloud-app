# Expose API Gateway URL, DynamoDB table name, and other details as outputs for easy reference after deployment.
resource "aws_api_gateway_deployment" "todo_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  stage_name  = "prod"
}

output "api_url" {
  value = "${aws_api_gateway_rest_api.todo_api.execution_arn}/${aws_api_gateway_deployment.todo_api_deployment.stage_name}"
}
