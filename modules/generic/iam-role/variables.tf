variable "name" {
  description = "The name of the role"
  type        = string
}

variable "trusted_principals" {
  description = "The entity that the role will trust"

  type = list(object({
    type        = string
    identifiers = list(string)
    external_id = optional(string)
  }))

  # validation {
  #   condition     = can(regex("^(Service|AWS)$", var.trusted_principals.type))
  #   error_message = "The principal_type must be either Service or AWS"
  # }
  default = null
}

variable "trust_policy" {
  description = "The trust policy for the role"
  type        = string
  default     = null
}

variable "policy_document" {
  description = "The policy document for the role"
  type        = string
  default     = null
}

variable "create_policy" {
  description = "Whether to create a policy for the role"
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "A list of ARNs for managed policies to attach to the role"
  type        = set(string)
  default     = []
}
