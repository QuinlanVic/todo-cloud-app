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