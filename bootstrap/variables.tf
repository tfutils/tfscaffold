variable "project" {
  type        = string
  description = "The name of the Project we are bootstrapping TFScaffold for"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID into which we are bootstrapping TFScaffold"
}

variable "aws_region" {
  type        = string
  description = "The AWS Region into which we are bootstrapping TFScaffold"
}

variable "environment" {
  type        = string
  description = "The name of the environment for the bootstrapping process"
  default     = "bootstrap"
}

variable "component" {
  type        = string
  description = "The name of the component for the bootstrapping process"
  default     = "bootstrap"
}

variable "bucket_name" {
  type        = string
  description = "The name to use for the TFScaffold bucket (and DDB Lock table)"
}
