# Set up Amazon Cognito to handle user registration and login, which integrates with API Gateway to secure endpoints.
# cognito.tf
# Creates a new Cognito User Pool named "TodoAppUserPool"
# A User Pool in Amazon Cognito is a user directory where users can sign up and log in. 
# It provides built-in authentication functionalities such as user registration, account recovery, and multi-factor authentication (MFA).
resource "aws_cognito_user_pool" "user_pool" {
  name = "TodoAppUserPool"
}
# Creates a client application for the "TodoAppUserPool".
# The User Pool Client acts as an interface between applications (e.g., a web or mobile app) and the Cognito User Pool. 
# It allows the app to interact with the User Pool for operations like login, signup, and token retrieval.
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "TodoAppUserPoolClient"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}