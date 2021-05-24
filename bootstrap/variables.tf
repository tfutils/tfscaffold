variable "project" {
  type        = string
  description = "The name of the Project we are bootstrapping tfscaffold for"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS Account ID into which we are bootstrapping tfscaffold"
}

variable "region" {
  type        = string
  description = "The AWS Region into which we are bootstrapping tfscaffold"
}

variable "environment" {
  type        = string
  description = "The name of the environment for the bootstrapping process; which is always bootstrap"
  default     = "bootstrap"
}

variable "component" {
  type        = string
  description = "The name of the component for the bootstrapping process; which is always bootstrap"
  default     = "bootstrap"
}

variable "bucket_name" {
  type        = string
  description = "The name to use for the tfscaffold bucket. This should be provided from tfscaffold shell, not environment or group tfvars"
}

variable "tfscaffold_ro_principals" {
  type        = list(string)
  description = "A list of Principals permitted to ListBucket and GetObject for Remote State purposes. Normally the root principal of the account"
  default     = []
}
