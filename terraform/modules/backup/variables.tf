variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. prod, staging)."
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for encrypting backups in the vault."
  default     = null
}

variable "force_destroy" {
  type        = bool
  description = "Whether to delete recovery points when destroying the backup vault."
  default     = false
}

variable "backup_schedule" {
  type        = string
  description = "Cron expression for the backup plan schedule."
  default     = "cron(0 5 ? * * *)"
}

variable "backup_start_window" {
  type        = number
  description = "Minutes after the scheduled time that a backup may start."
  default     = 60
}

variable "backup_completion_window" {
  type        = number
  description = "Minutes after the scheduled time that a backup must complete."
  default     = 180
}

variable "backup_delete_after_days" {
  type        = number
  description = "Number of days after which recovery points are deleted."
  default     = 30
}

variable "enable_continuous_backup" {
  type        = bool
  description = "Whether to enable continuous backup for supported resources."
  default     = false
}

variable "rds_resource_arns" {
  type        = list(string)
  description = "ARNs of RDS instances or clusters to include in backup selection."
  default     = []
}

variable "rds_selection_tags" {
  type        = map(string)
  description = "Tag-based selection for RDS resources when ARNs are not provided."
  default     = {}
}

variable "iam_role_arn" {
  type        = string
  description = "Existing IAM role ARN for AWS Backup. Created automatically when null."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources."
  default     = {}
}
