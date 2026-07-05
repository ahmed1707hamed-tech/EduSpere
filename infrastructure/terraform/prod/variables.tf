variable "project_name" { type = string }
variable "region" { type = string }

variable "vpc_cidr" { type = string }

variable "public_subnet_1_cidr" { type = string }
variable "public_subnet_2_cidr" { type = string }

variable "private_app_subnet_1_cidr" { type = string }
variable "private_app_subnet_2_cidr" { type = string }

variable "private_db_subnet_1_cidr" { type = string }
variable "private_db_subnet_2_cidr" { type = string }

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed to access admin-only ports (e.g., SSH)."
  type        = list(string)
  default     = []
}