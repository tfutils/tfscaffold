variable "aws_account_id" {
  type = "string"
}

variable "region" {
  type    = "string"
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
