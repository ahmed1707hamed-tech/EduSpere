variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDR ranges allowed to reach the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_ipv6_cidrs" {
  description = "IPv6 CIDR ranges allowed to reach the public ALB."
  type        = list(string)
  default     = []
}

variable "application_ports" {
  description = "Application ports exposed behind the ALB."
  type        = list(number)
  default     = [80, 443, 8080]
}

variable "enable_k3s_api_access" {
  description = "Enable restricted inbound access to the k3s API port."
  type        = bool
  default     = false
}

variable "k3s_api_allowed_cidrs" {
  description = "IPv4 CIDR ranges allowed to access k3s API when enabled."
  type        = list(string)
  default     = []
}

variable "postgres_port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "egress_cidrs" {
  description = "IPv4 CIDR ranges allowed for egress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
