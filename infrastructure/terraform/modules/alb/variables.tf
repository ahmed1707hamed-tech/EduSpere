variable "project_name" {
  type = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for the ALB and target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Existing security group ID for the ALB."
  type        = string
}

variable "target_instance_id" {
  description = "EC2 instance ID to register in the target group."
  type        = string
}

variable "target_port" {
  description = "Target port on the instance."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP health check path."
  type        = string
  default     = "/"
}

