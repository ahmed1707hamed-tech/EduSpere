variable "project_name" {
  type        = string
  description = "Name of the project used for resource naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-30 characters, lowercase alphanumeric and hyphens, starting with a letter."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources."
  default     = {}
}

variable "deletion_window_in_days" {
  type        = number
  description = "KMS key deletion window in days."
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic annual key rotation."
  default     = true
}

variable "rds_admin_role_arns" {
  type        = list(string)
  description = "IAM role ARNs allowed to administer the RDS KMS key."
  default     = []
}

variable "s3_admin_role_arns" {
  type        = list(string)
  description = "IAM role ARNs allowed to administer the S3 KMS key."
  default     = []
}

variable "secrets_admin_role_arns" {
  type        = list(string)
  description = "IAM role ARNs allowed to administer the Secrets Manager KMS key."
  default     = []
}

variable "logs_admin_role_arns" {
  type        = list(string)
  description = "IAM role ARNs allowed to administer the CloudWatch Logs KMS key."
  default     = []
}
