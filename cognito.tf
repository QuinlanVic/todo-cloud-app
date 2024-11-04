# Set up Amazon Cognito to handle user registration and login, which integrates with API Gateway to secure endpoints.
# cognito.tf
resource "aws_cognito_user_pool" "user_pool" {
  name = "TodoAppUserPool"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "TodoAppUserPoolClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}