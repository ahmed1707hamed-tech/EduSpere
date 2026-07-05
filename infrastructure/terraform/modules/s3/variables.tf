variable "project_name" {
  type = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "bucket_prefix" {
  description = "Optional prefix for bucket names. If empty, project_name is used."
  type        = string
  default     = ""
}

variable "lifecycle_expire_days" {
  description = "Number of days after which objects expire (0 disables expiration)."
  type        = number
  default     = 0
}

