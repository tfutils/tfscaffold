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

variable "deletion_window" {
  type        = number
  description = "KMS key deletion window in days"
  default     = 7
}

variable "alias" {
  type        = string
  description = "Alias name for the KMS key (to be prefixed with alias/). Set to 'csi' to use the module's CSI alias naming convention"
  default     = "null"
}

variable "key_policy_documents" {
  type        = list(string)
  description = "List of KMS key policy JSON documents"
  default     = []
}

variable "iam_delegation" {
  type        = bool
  description = "Whether to delegate administration of the key to the local account. Defaults to true"
  default     = true
}

variable "create_policies" {
  type        = bool
  description = "Whether to create Admin and User IAM policies for the KMS key. Defaults to true"
  default     = true
}

variable "rotation" {
  type        = bool
  description = "Whether to enable key rotation. Defaults to true"
  default     = true
}

variable "bypass_policy_lockout_safety_check" {
  type        = bool
  description = "Whether to bypass the policy lockout safety check. Defaults to false. Only set to true if you are sure you want to do this."
  default     = false
}

variable "description" {
  type        = string
  description = "Description of the KMS key (to be prefixed with CSI)"
  default     = null
}
