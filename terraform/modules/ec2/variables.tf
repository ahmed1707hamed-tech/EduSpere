variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2 k3s hosts."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs assigned to k3s hosts."
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances."
  type        = string
}

variable "instance_count" {
  description = "Number of k3s EC2 instances."
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type for k3s hosts."
  type        = string
  default     = "t3.large"
}

variable "ami_id" {
  description = "AMI ID. When null, latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "ami_owners" {
  description = "AMI owners used by the default AMI lookup."
  type        = list(string)
  default     = ["amazon"]
}

variable "ami_name_filter" {
  description = "AMI name filter used when ami_id is null."
  type        = string
  default     = "al2023-ami-*-x86_64"
}

variable "ami_architecture" {
  description = "AMI CPU architecture."
  type        = string
  default     = "x86_64"
}

variable "ssh_key_name" {
  description = "Optional EC2 key pair name. Prefer SSM Session Manager in production."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script for k3s bootstrap."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 80
}

variable "root_volume_type" {
  description = "Root volume type."
  type        = string
  default     = "gp3"
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID or ARN used for root volume encryption."
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
