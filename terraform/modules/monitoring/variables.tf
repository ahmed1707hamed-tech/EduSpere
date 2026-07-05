variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "alert_email_endpoints" {
  description = "Email endpoints subscribed to SNS alerts."
  type        = list(string)
  default     = []
}

variable "sns_kms_key_id" {
  description = "Optional KMS key ID for SNS."
  type        = string
  default     = "alias/aws/sns"
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch dimensions."
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance identifier."
  type        = string
}

variable "redis_replication_group_id" {
  description = "Redis replication group ID."
  type        = string
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs to monitor."
  type        = list(string)
  default     = []
}

variable "alarm_period" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 300
}

variable "alarm_evaluation_periods" {
  description = "CloudWatch alarm evaluation periods."
  type        = number
  default     = 2
}

variable "alb_5xx_threshold" {
  description = "ALB 5xx count threshold."
  type        = number
  default     = 10
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization threshold."
  type        = number
  default     = 80
}

variable "redis_cpu_threshold" {
  description = "Redis CPU utilization threshold."
  type        = number
  default     = 75
}

variable "backup_role_arn" {
  description = "AWS Backup IAM role ARN."
  type        = string
}

variable "backup_resource_arns" {
  description = "Resource ARNs protected by AWS Backup."
  type        = list(string)
  default     = []
}

variable "backup_schedule" {
  description = "AWS Backup cron schedule."
  type        = string
  default     = "cron(0 3 * * ? *)"
}

variable "backup_start_window_minutes" {
  description = "Backup start window in minutes."
  type        = number
  default     = 60
}

variable "backup_completion_window_minutes" {
  description = "Backup completion window in minutes."
  type        = number
  default     = 180
}

variable "backup_cold_storage_after_days" {
  description = "Days before backups transition to cold storage."
  type        = number
  default     = 30
}

variable "backup_delete_after_days" {
  description = "Days before backups are deleted."
  type        = number
  default     = 365
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
