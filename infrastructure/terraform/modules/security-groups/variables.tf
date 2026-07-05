variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed to access admin-only ports (e.g., SSH). Prefer a corporate VPN CIDR."
  type        = list(string)
  default     = []
}