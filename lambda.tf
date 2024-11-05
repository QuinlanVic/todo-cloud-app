# Use Terraform to upload and manage these Lambda functions.
# lambda.tf
resource "aws_lambda_function" "create_todo" {
  filename         = "all_lambda_functions.zip" # Zip your Lambda code
  function_name    = "createTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_functions.create_todo.handler"
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = "Todos"
    }
  }
}

# Repeat for other Lambda functions (getTodos, updateTodo, deleteTodo)
resource "aws_lambda_function" "get_todos" {
  filename         = "all_lambda_functions.zip" # Zip your Lambda code
  function_name    = "getTodosFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_functions.get_todos.handler"
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = "Todos"
    }
  }
}

resource "aws_lambda_function" "update_todo" {
  filename         = "all_lambda_functions.zip" # Zip your Lambda code
  function_name    = "updateTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_functions.update_todo.handler"
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = "Todos"
    }
  }
}

resource "aws_lambda_function" "delete_todo" {
  filename         = "all_lambda_functions.zip" # Zip your Lambda code
  function_name    = "deleteTodoFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_functions.delete_todo.handler"
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = "Todos"
    }
  }
}