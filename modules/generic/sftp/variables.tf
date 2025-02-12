variable "project" {
  type        = string
  description = "The project name"
}

variable "environment" {
  type        = string
  description = "The project name"
}

variable "component" {
  type        = string
  description = "The component name"
}

variable "module" {
  type        = string
  description = "This module name"
  default     = "sftp"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all taggable resources"
  default     = {}
}

variable "name" {
  type        = string
  description = "A common name for resources used in this module"
}

variable "users" {
  type = map(map(string))
  #   bucket      = string
  #   name        = string
  #   folder      = string
  #   permissions = string
  #   public_key  = string

  description = "Set of user objects for SFTP"
  default     = {}
}

variable "sftp_endpoint_type" {
  type        = string
  description = "SFTP Endpoint Type" 
  default     = "PUBLIC"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "subnet_ids" { 
  type        = list(string)
  description = "Subnet IDs for SFTP Endpoint in VPC Mode"
  default     = []
}
