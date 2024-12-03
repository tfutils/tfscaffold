##
# Basic Required Variables for tfscaffold Components
##

variable "tfscaffold_bucket_prefix" {
  type        = string
  description = "The tfscaffold bucket prefix (mostly for constructing remote states)"
}

variable "project" {
  type        = string
  description = "The tfscaffold project"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID (numeric)"
}

variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "group" {
  type        = string
  description = "The group variables are being inherited from (often synonmous with account short-name)"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The environment variables are being inherited from"
}

##
# tfscaffold variables specific to this component
##

variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the component"
  default     = {}
}

##
# Variables specific to the "example" Component
##

variable "bucket_name" {
  type        = string
  description = "(Suffix for) the name for the name of the S3 bucket"
}
