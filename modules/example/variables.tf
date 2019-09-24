# GENERAL
variable "project" {
  type        = "string"
  description = "The project name (comes from component)"
}

variable "environment" {
  type        = "string"
  description = "The environment name (comes from component)"
}

variable "component" {
  type        = "string"
  description = "The TF component name (comes from component)"
}

variable "module" {
  type        = "string"
  description = "The module name"
  default     = "example"
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to be applied to all taggable resources ( main ones come from component)"
  default     = {}
}

# SPECIFIC
# ...
