# Expose API Gateway URL, DynamoDB table name, and other details as outputs for easy reference after deployment.
output "api_url" {
  value = aws_api_gateway_rest_api.todo_api.execution_arn
}