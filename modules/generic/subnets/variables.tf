##
# Generic tfscaffold Module Variables
##

variable "aws" {
  type = object({
    account_id   = string
    default_tags = optional(map(string), {})
    partition    = optional(string, "aws")
    region       = string
    url_suffix   = optional(string, "amazonaws.com")
  })
}

variable "module_parents" {
  type        = list(string)
  description = "List of parent module names"
  default     = []
}

variable "unique_ids" {
  type = object({
    # All marked as optional for consistency of code.
    # Whether each is optional depends on the module implementation.
    local   = optional(string, null)
    account = optional(string, null)
    global  = optional(string, null)
  })
}

##
# Variables specific to this Module
##

variable "availability_zones" {
  type        = list(string)
  description = "A list of availablity zones for subnets creation"
  default     = []
}

variable "cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks used for blue subnets creation - defines the total number to be created"
  default     = []
}

variable "map_public_ip_on_launch" {
  type        = string
  description = "Specify true to indicate that instances should be assigned a public IP address"
  default     = false
}

variable "route_tables" {
  type        = list(string)
  description = "A list of route tables for subnets association. Specify one route table to be shared by all subnets or one route table for each subnet"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

