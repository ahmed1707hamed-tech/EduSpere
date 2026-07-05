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
  type    = list(string)
  default = []
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "ec2_iam_instance_profile_name" {
  description = "Existing IAM instance profile name to attach to the EC2 instance."
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "rds_username" {
  description = "RDS master username."
  type        = string
}

variable "rds_password" {
  description = "RDS master password."
  type        = string
  sensitive   = true
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for RDS."
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS."
  type        = bool
  default     = true
}

variable "bucket_prefix" {
  description = "Prefix used for S3 bucket names."
  type        = string
  default     = ""
}

variable "alarm_email_endpoints" {
  description = "Email endpoints subscribed to the alarms SNS topic."
  type        = list(string)
  default     = []
}

