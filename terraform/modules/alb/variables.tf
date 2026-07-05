variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the ALB."
  type        = list(string)
}

variable "target_instance_ids" {
  description = "Instance IDs registered with the target group when target_type is instance."
  type        = list(string)
  default     = []
}

variable "target_type" {
  description = "ALB target type."
  type        = string
  default     = "instance"
}

variable "target_port" {
  description = "Application target port."
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Application target protocol."
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/health"
}

variable "health_check_matcher" {
  description = "Expected health check response matcher."
  type        = string
  default     = "200-399"
}

variable "health_check_interval" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds."
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold count."
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count."
  type        = number
  default     = 3
}

variable "enable_https" {
  description = "Enable HTTPS listener and HTTP to HTTPS redirect."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "ALB TLS security policy."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60
}

variable "access_logs_bucket" {
  description = "Optional S3 bucket name for ALB access logs."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "ALB access log prefix."
  type        = string
  default     = "alb"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
