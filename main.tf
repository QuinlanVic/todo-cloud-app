# main.tf

variable "access_key_aws" {
  description = "access key for AWS account"
  type        = string
}

variable "secret_key_aws" {
  description = "secret key for AWS account"
  type        = string
}

variable "token_session" {
  description = "session token for AWS account"
  type        = string
}

provider "aws" {
  region = "eu-north-1"
    # implement safer storage later 
  access_key = var.access_key_aws
  secret_key = var.secret_key_aws
  token      = var.token_session
}
# Create an IAM role that allows Lambda functions to execute and access DynamoDB, S3, and other necessary services.
# Given necessary permissions via Terraform
# iam.tf
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# add policy for Full DynamoDB Access for lambda functions
resource "aws_iam_policy_attachment" "lambda_dynamodb_policy" {
  name       = "lambda_dynamodb_policy"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# # dynamodb.tf
# resource "aws_dynamodb_table" "todo_table" {
#   name         = "TodoTable"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "id"

#   attribute {
#     name = "id"
#     type = "S"
#   }
# }

# Use Terraform to upload and manage these Lambda functions.
# lambda.tf
resource "aws_lambda_function" "create_todo" {
  filename         = "lambda_create_todo.zip" # Zip your Lambda code
  function_name    = "createTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_create_todo.handler"
  runtime          = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }
}

# Repeat for other Lambda functions (getTodos, updateTodo, deleteTodo)
resource "aws_lambda_function" "get_todos" {
  filename         = "lambda_get_todos.zip" # Zip your Lambda code
  function_name    = "getTodosFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_get_todos.handler"
  runtime          = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }
}

resource "aws_lambda_function" "update_todo" {
  filename         = "lambda_update_todo.zip" # Zip your Lambda code
  function_name    = "updateTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_update_todo.handler"
  runtime          = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }
}

resource "aws_lambda_function" "delete_todo" {
  filename         = "lambda_delete_todo.zip" # Zip your Lambda code
  function_name    = "deleteTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_delete_todo.handler"
  runtime          = "nodejs14.x"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todo_table.name
    }
  }
}

# Create an API Gateway to expose your Lambda functions as a REST API.
# api_gateway.tf
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "TodoAPI"
  description = "API for managing todos"
}

resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

resource "aws_api_gateway_method" "create_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_todo_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.create_todo.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.create_todo.invoke_arn
}

# Repeat for other CRUD operations (GET, PUT, DELETE)





