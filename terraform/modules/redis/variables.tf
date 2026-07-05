variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and tags."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ElastiCache is deployed."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the ElastiCache subnet group."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to the Redis cluster."
}

variable "node_type" {
  type        = string
  default     = "cache.t3.medium"
  description = "ElastiCache node instance type."
}

variable "engine_version" {
  type        = string
  default     = "7.1"
  description = "Redis engine version."
}

variable "num_cache_clusters" {
  type        = number
  default     = 2
  description = "Number of cache nodes (primary + replicas). Must be at least 2 for automatic failover."
}

variable "port" {
  type        = number
  default     = 6379
  description = "Redis port."
}

variable "snapshot_retention_limit" {
  type        = number
  default     = 7
  description = "Number of days to retain automatic snapshots."
}

variable "snapshot_window" {
  type        = string
  default     = "02:00-03:00"
  description = "Daily snapshot window in UTC."
}

variable "maintenance_window" {
  type        = string
  default     = "sun:03:00-sun:04:00"
  description = "Weekly maintenance window in UTC."
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = true
  description = "Enable automatic failover. Requires num_cache_clusters >= 2."
}

variable "at_rest_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable encryption at rest."
}

variable "transit_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable encryption in transit."
}

variable "parameter_group_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Additional Redis parameter group settings."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources."
}
