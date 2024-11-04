# s3.tf
resource "aws_s3_bucket" "todo_bucket" {
  bucket = "my-todo-app-bucket"
}