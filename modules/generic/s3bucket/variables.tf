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

variable "bucket_key_enabled" {
  type        = bool
  description = "Boolean to toggle bucket key enablement"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Boolean to toggle force destroy of bucket. Defaults to true; should be changed in exceptional circumstances"
  default     = true
}

variable "prevent_destroy" {
  type        = bool
  description = "Whether to prevent the bucket's destruction with a lifecycle rule"
  default     = false
}

variable "bucket_name" {
  type        = string
  description = "The variable encapsulating the name of this bucket"
  default     = null
}

variable "cors_rules" {
  type = set(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    id              = optional(string, null)
    max_age_seconds = optional(number, 0)
  }))

  description = "A set of CORS rules to apply to the bucket"
  default     = []
}

variable "expected_bucket_owner" {
  type        = string
  description = <<-EOT
    The expected account ID of the bucket owner.
    
    CAUTION: This should usually be left as null, however when importing buckets,
    this will likely be set to the account ID of the bucket owner.
    While not incorrect, resources that take an expected_bucket_owner property will
    be tainted if the value is changed. Therefore, not setting this when it has been
    set during import can cause these objects to be recreated.
  EOT

  default = null
}

variable "policy_documents" {
  type        = list(string)
  description = "A list of JSON policies to use to build the bucket policy"
  default     = []
}

variable "acl" {
  type        = string
  description = "Canned ACL to set on the bucket. Only used if ownership is not set to BucketOwnerEnforced"
  default     = null
}

variable "accelerate_configuration" {
  type        = bool
  description = "The accelerate configuration of the bucket. true == Enabled"
  default     = false
}

variable "lifecycle_rules" {
  type = object({
    prefix = string

    noncurrent_version_transition = optional(list(object({
      days          = string
      storage_class = string
    })), [])

    transition = optional(list(object({
      days          = string
      storage_class = string
    })), [])

    noncurrent_version_expiration = optional(object({
      days = string
    }), { days = "-1" })

    expiration = optional(object({
      days = string
    }), { days = "-1" })
  })

  description = "Object representing the lifecycle rules of the bucket"
  default     = null
}

variable "public_access" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })

  description = "Object representing the public access rules of the bucket"

  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "bucket_logging_target" {
  type        = map(string)
  description = "Map of S3 bucket access logging target properties"
  default     = {}

  # Expected value:
  # {
  #   bucket = "my_bucket"
  #   prefix = "custom_prefix" // optional, defaults to name of bucket
  # }
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of default encryption KMS key for this bucket. If omitted, will use AES256"
  default     = null
}

variable "versioning" {
  type        = bool
  description = "Toggle for versioning the bucket. Defaults to true"
  default     = true
}

variable "object_ownership" {
  type        = string
  description = "Ownership of objects written to the bucket"
  default     = "BucketOwnerEnforced"

  # Unspecified is permitted here only to allow the import of a bucket
  # that was created prior to the introduction BucketOwnershipControls
  # where no BucketOwnershipControls object exists, and the fallback
  # is ObjectWriter without it being explicitly set.
  validation {
    condition = (
      var.object_ownership == "BucketOwnerEnforced"
      || var.object_ownership == "BucketOwnerPreferred"
      || var.object_ownership == "ObjectWriter"
      || var.object_ownership == "Unspecified"
    )

    error_message = "Must be one of 'BucketOwnerEnforced', 'BucketOwnerPreferred', 'ObjectWriter', or 'Unspecified'"
  }
}
