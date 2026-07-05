variable "project_name" {
  type = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "instance_id" {
  description = "EC2 instance ID to monitor."
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name."
  type        = string
  default     = ""
}

variable "alarm_email_endpoints" {
  description = "Email endpoints to subscribe to the SNS topic."
  type        = list(string)
  default     = []
}

