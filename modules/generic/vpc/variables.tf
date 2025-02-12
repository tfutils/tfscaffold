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
# Variable specific to the module
##

variable "nat" {
  type = object({
    availability_zones   = optional(list(string), null)
    gateway_count        = number
    subnets_default_tags = optional(map(string), {})

    # NEVER set this to true.
    # This is here only to allow for importing of legacy infrastucture
    subnets_map_public_ip_on_launch = optional(bool, false)

    subnets_netnum_root = number
    subnets_newbits     = number
  })

  description = <<-EOF
    The NAT Gateway configuration for the VPC

    availability_zones  = The list of availability zones to spread NAT subnets across - defaults to all available zones
    gateway_count       = The number of NAT Gateways (and therefore NAT Gateway subnets) to create
    subnets_netnum_root = The first subnet network number with relation to the VPC CIDR block
    subnets_newbits     = The number of bits to add to the subnet mask

    Implemented using the terraform cidrsubnet function:
    https://developer.hashicorp.com/terraform/language/functions/cidrsubnet

    [ for i in range(gateway_count): cidrsubnet(var.vpc_cidr, subnets_newbits, subnets_netnum_root + i) ]
    
    Example 1:

    vpc_cidr = "10.10.0.0/16", gateway_count = 3, subnets_netnum_root = 4093, subnets_newbits = 12
    
    AZ1: 10.10.255.208/28
    AZ2: 10.10.255.224/28
    AZ3: 10.10.255.240/28

    Example 2:

    vpc_cidr = "10.10.0.0/20", gateway_count = 2, subnets_netnum_root = 0, subnets_newbits = 4

    AZ1: 10.10.0.0/24
    AZ2: 10.10.1.0/24
  EOF

  default = null
}

variable "root_domain_name" {
  type        = string
  description = "The root domain name assigned to the account"
  default     = null
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the base VPC"
}

variable "vpc_secondary_cidrs" {
  type        = set(string)
  description = "Additional CIDR blocks for the base VPC (csv) (optional)"
  default     = []
}
