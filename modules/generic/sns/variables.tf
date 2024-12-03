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
    local   = string
    account = optional(string, null) # Not used in this module
    global  = optional(string, null) # Not used in this module
  })
}

##
# Variables specific to this Module
##

variable "topic_name" {
  type        = string
  description = "If set, the full name of the SNS Topic, otherwise it will be set to the CSI"
  default     = null
}

variable "display_name" {
  type        = string
  description = "If set, the 'Display Name' of the SNS Topic, otherwise it will be set to the same as the topic name"
  default     = null
}

variable "content_based_deduplication" {
  type        = bool
  description = "Enables content-based deduplication for FIFO topics."
  default     = null
}

variable "delivery_policy" {
  type        = string
  description = "The SNS delivery policy"
  default     = null
}

variable "fifo_topic" {
  type        = bool
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false)."
  default     = false
}

variable "iam_policy_documents" {
  type        = list(string)
  description = "IAM Policy Documents to combine into the SNS Topic Policy, using the source_policies parameter"
  default     = []
}

variable "kms_master_key_id" {
  type        = string
  description = "KMS CMK for Message Encryption"
  default     = null
}

variable "log_retention_in_days" {
  type        = number
  description = "Log retention period in days for the feedback cloudwatch log group"
  default     = 365 # NIST
}

variable "publishing_service_principals" {
  type        = list(string)
  description = "A list of service principals to be granted SNS:Publish permission to the SNS topic, obviating the need to declare a whole topic policy document independently to permit it. e.g., [ codepipeline.$${var.aws[\"url_suffix\"]} ]"
  default     = []
}

variable "signature_version" {
  type        = string
  description = "If SignatureVersion should be 1 (SHA1) or 2 (SHA256). The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS."
  default     = null
}

variable "tracing_config" {
  type        = string
  description = "Tracing mode of an Amazon SNS topic. Valid values: 'PassThrough', 'Active'."
  default     = null
}

##
# SNS Feedback (Delivery Status Logging)
##

# Defaults for Endpoints

variable "default_feedback_role_arn" {
  type        = string
  description = "Default Success/Failure Feedback Role ARN for all endpoints"
  default     = null
}

variable "default_failure_feedback_role_arn" {
  type        = string
  description = "Default Success/Failure Feedback Role ARN for all endpoints"
  default     = null
}

variable "default_success_feedback_role_arn" {
  type        = string
  description = "Default Success/Failure Feedback Role ARN for all endpoints"
  default     = null
}

variable "default_success_feedback_sample_rate" {
  type        = number
  description = "Default Success Feedback Sample Rate for all endpoints"
  default     = 100
}

# Application

variable "application_failure_feedback_role_arn" {
  type        = string
  description = "Role ARN for application endpoint delivery success"
  default     = null
}

variable "application_success_feedback_role_arn" {
  type        = string
  description = "Role ARN for application endpoint delivery success"
  default     = null
}

variable "application_success_feedback_sample_rate" {
  type        = string
  description = "Role ARN for application endpoint delivery success"
  default     = null
}

# Firehose

variable "firehose_failure_feedback_role_arn" {
  type        = string
  description = "Role ARN for firehose endpoint delivery success"
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  type        = string
  description = "Role ARN for firehose endpoint delivery success"
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  type        = string
  description = "Role ARN for firehose endpoint delivery success"
  default     = null
}

# HTTP

variable "http_failure_feedback_role_arn" {
  type        = string
  description = "Role ARN for http endpoint delivery success"
  default     = null
}

variable "http_success_feedback_role_arn" {
  type        = string
  description = "Role ARN for http endpoint delivery success"
  default     = null
}

variable "http_success_feedback_sample_rate" {
  type        = string
  description = "Role ARN for http endpoint delivery success"
  default     = null
}

# Lambda

variable "lambda_failure_feedback_role_arn" {
  type        = string
  description = "Role ARN for lambda endpoint delivery success"
  default     = null
}

variable "lambda_success_feedback_role_arn" {
  type        = string
  description = "Role ARN for lambda endpoint delivery success"
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  type        = string
  description = "Role ARN for lambda endpoint delivery success"
  default     = null
}

# SQS

variable "sqs_failure_feedback_role_arn" {
  type        = string
  description = "Role ARN for sqs endpoint delivery success"
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  type        = string
  description = "Role ARN for sqs endpoint delivery success"
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  type        = string
  description = "Role ARN for sqs endpoint delivery success"
  default     = null
}
