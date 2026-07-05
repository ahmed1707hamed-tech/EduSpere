variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Public subnet ID to place the EC2 instance in."
  type        = string
}

variable "security_group_id" {
  description = "Existing security group ID for the instance."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name to attach to the instance."
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Root volume size in GB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring on the instance."
  type        = bool
  default     = true
}

