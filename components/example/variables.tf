# GENERAL
variable "aws_region" {
  type        = "string"
  description = "The AWS Region"
  default     = "eu-west-1"
}

variable "project" {
  type        = "string"
  description = "The Project name"
  default     = "lab"
}

variable "environment" {
  type        = "string"
  description = "The environment name"
}

variable "component" {
  type        = "string"
  description = "The TF component name"
  default     = "example"
}

# SPECIFIC
# ...
