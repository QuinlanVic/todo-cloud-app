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









