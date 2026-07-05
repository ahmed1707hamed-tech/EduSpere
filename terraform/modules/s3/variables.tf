variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "buckets" {
  description = "S3 bucket configuration map."
  type = map(object({
    name                       = string
    data_class                 = optional(string, "application")
    force_destroy              = optional(bool, false)
    versioning_enabled         = optional(bool, true)
    sse_algorithm              = optional(string, "aws:kms")
    bucket_key_enabled         = optional(bool, true)
    transition_days            = optional(number)
    expiration_days            = optional(number)
    noncurrent_transition_days = optional(number, 30)
    noncurrent_expiration_days = optional(number, 365)
    tags                       = optional(map(string), {})
  }))
}

variable "create_terraform_lock_table" {
  description = "Create the DynamoDB table used for Terraform state locking."
  type        = bool
  default     = true
}

variable "terraform_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
