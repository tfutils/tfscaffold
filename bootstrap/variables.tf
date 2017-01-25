variable "aws_account_id" {
  type = "string"
}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "environment" {
  type    = "string"
  default = "bootstrap"
}

variable "project" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}
