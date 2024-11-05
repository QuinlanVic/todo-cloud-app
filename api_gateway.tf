# Create an API Gateway to expose your Lambda functions as a REST API.
# api_gateway.tf
# Creates an API named "TodoAPI" with a description.
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "TodoAPI"
  description = "API for managing todos"
}
# Adds a resource path "/todos" under the root path of "TodoAPI."
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}
# Each HTTP method (POST, GET, PUT, DELETE) is set up to allow CRUD operations on /todos.
# Specifies the HTTP method (e.g., POST for creating a todo) and configures it without authorization.
resource "aws_api_gateway_method" "create_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}
# Links the API method to a specific Lambda function using AWS_PROXY
resource "aws_api_gateway_integration" "create_todo_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.create_todo.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_todo.invoke_arn
}

# Repeat for other CRUD operations (GET, PUT, DELETE)
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_todos_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.get_todos.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_todos.invoke_arn
}
# PUT
resource "aws_api_gateway_method" "update_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_todo_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.update_todo.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.update_todo.invoke_arn
}
# DELETE
resource "aws_api_gateway_method" "delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_todo_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.delete_todo.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.delete_todo.invoke_arn
}


