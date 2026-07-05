variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "database_subnet_ids" {
  description = "Private database subnet IDs."
  type        = list(string)
}

variable "rds_security_group_ids" {
  description = "Security group IDs attached to PostgreSQL."
  type        = list(string)
}

variable "redis_security_group_ids" {
  description = "Security group IDs attached to Redis."
  type        = list(string)
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30
}

variable "secret_recovery_window_in_days" {
  description = "Secrets Manager recovery window in days."
  type        = number
  default     = 30
}

variable "db_password_length" {
  description = "Generated database password length."
  type        = number
  default     = 32
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum autoscaled RDS storage in GiB."
  type        = number
}

variable "db_storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"
}

variable "db_multi_az" {
  description = "Deploy RDS in Multi-AZ mode."
  type        = bool
  default     = true
}

variable "db_backup_retention_days" {
  description = "RDS automated backup retention in days."
  type        = number
  default     = 30
}

variable "db_backup_window" {
  description = "Preferred RDS backup window."
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred RDS maintenance window."
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS."
  type        = bool
  default     = false
}

variable "db_enabled_cloudwatch_logs_exports" {
  description = "PostgreSQL logs exported to CloudWatch."
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "db_performance_insights_enabled" {
  description = "Enable RDS Performance Insights."
  type        = bool
  default     = true
}

variable "db_iam_authentication_enabled" {
  description = "Enable IAM database authentication."
  type        = bool
  default     = true
}

variable "db_auto_minor_version_upgrade" {
  description = "Enable RDS automatic minor version upgrades."
  type        = bool
  default     = true
}

variable "db_apply_immediately" {
  description = "Apply RDS modifications immediately."
  type        = bool
  default     = false
}

variable "db_parameter_group_family" {
  description = "PostgreSQL parameter group family."
  type        = string
}

variable "db_parameters" {
  description = "PostgreSQL parameter map."
  type = map(object({
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = {}
}

variable "redis_auth_token" {
  description = "Optional Redis auth token. When null, a token is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "redis_auth_token_length" {
  description = "Generated Redis auth token length."
  type        = number
  default     = 40
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
}

variable "redis_parameter_group_family" {
  description = "Redis parameter group family."
  type        = string
}

variable "redis_node_type" {
  description = "Redis node type."
  type        = string
}

variable "redis_port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "redis_node_count" {
  description = "Number of Redis cache nodes."
  type        = number
  default     = 2
}

variable "redis_automatic_failover_enabled" {
  description = "Enable Redis automatic failover."
  type        = bool
  default     = true
}

variable "redis_multi_az_enabled" {
  description = "Enable Redis Multi-AZ."
  type        = bool
  default     = true
}

variable "redis_snapshot_retention_days" {
  description = "Redis snapshot retention in days."
  type        = number
  default     = 7
}

variable "redis_snapshot_window" {
  description = "Preferred Redis snapshot window."
  type        = string
  default     = "02:00-03:00"
}

variable "redis_maintenance_window" {
  description = "Preferred Redis maintenance window."
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "redis_auto_minor_version_upgrade" {
  description = "Enable Redis automatic minor version upgrades."
  type        = bool
  default     = true
}

variable "redis_apply_immediately" {
  description = "Apply Redis modifications immediately."
  type        = bool
  default     = false
}

variable "redis_parameters" {
  description = "Redis parameter map."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
