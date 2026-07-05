variable "project_name" {
  type = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "db_subnet_ids" {
  description = "Private DB subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing security group ID for RDS."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "edusphere"
}

variable "username" {
  description = "Master username."
  type        = string
}

variable "password" {
  description = "Master password."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage_gb" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type."
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Enable Multi-AZ."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention in days."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the RDS instance."
  type        = bool
  default     = true
}