variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster."
  type        = string
}

variable "node_group_role_arn" {
  description = "IAM role ARN for EKS managed node group."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and node group."
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "Additional security group IDs for the EKS control plane."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private EKS API endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public EKS API endpoint."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Retention for EKS control plane logs."
  type        = number
  default     = 30
}

variable "log_kms_key_arn" {
  description = "KMS key ARN for EKS control plane CloudWatch logs."
  type        = string
  default     = null
}

variable "cluster_encryption_config_kms_key_arn" {
  description = "KMS key ARN for EKS secrets encryption."
  type        = string
  default     = null
}

variable "node_instance_types" {
  description = "Managed node group instance types."
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_ami_type" {
  description = "Managed node group AMI type."
  type        = string
  default     = "AL2_x86_64"
}

variable "node_capacity_type" {
  description = "Managed node group capacity type."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Managed node group disk size in GiB."
  type        = number
  default     = 80
}

variable "node_desired_size" {
  description = "Desired managed node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum managed node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum managed node count."
  type        = number
  default     = 6
}

variable "node_max_unavailable" {
  description = "Maximum unavailable nodes during node group updates."
  type        = number
  default     = 1
}

variable "node_release_version" {
  description = "Optional EKS optimized AMI release version."
  type        = string
  default     = null
}

variable "node_labels" {
  description = "Labels applied to managed nodes."
  type        = map(string)
  default     = {}
}

variable "cluster_addons" {
  description = "EKS add-ons to install."
  type = map(object({
    version = optional(string)
  }))
  default = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
