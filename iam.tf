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

# Attach the basic Lambda execution policy for CloudWatch logging
resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  name       = "lambda_execution_policy"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


variable "region" {
  default = "eu-north-1"  # or your specific region
}
# Get the current account ID dynamically
data "aws_caller_identity" "current" {}

# Custom policy for DynamoDB access to the specific Todos table
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "LambdaTodosTableAccessPolicy"
  description = "Policy to allow Lambda functions access to the specific Todos DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/Todos"
      }
    ]
  })
}

# Attach the custom policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}
