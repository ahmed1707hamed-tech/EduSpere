variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for flow logs."
  type        = string
}

variable "flow_logs_role_arn" {
  description = "IAM role ARN for VPC Flow Logs."
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs."
  type        = string
}

variable "cloudtrail_bucket_force_destroy" {
  description = "Force destroy CloudTrail bucket."
  type        = bool
  default     = false
}

variable "log_groups" {
  description = "CloudWatch log groups to create."
  type = map(object({
    name              = string
    retention_in_days = number
  }))
}

variable "include_global_service_events" {
  description = "Include global service events in CloudTrail."
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Enable CloudTrail in all regions."
  type        = bool
  default     = true
}

variable "vpc_flow_logs_traffic_type" {
  description = "VPC Flow Logs traffic type."
  type        = string
  default     = "ALL"
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
