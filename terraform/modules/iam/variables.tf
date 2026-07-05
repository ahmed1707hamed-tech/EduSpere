variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "application_bucket_arns" {
  description = "Application bucket ARNs accessible from compute."
  type        = list(string)
  default     = []
}

variable "secret_arns" {
  description = "Secrets Manager secret ARNs accessible from compute."
  type        = list(string)
  default     = []
}

variable "github_oidc_subjects" {
  description = "GitHub OIDC subject patterns allowed to assume the deployment role."
  type        = list(string)
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints for the GitHub Actions OIDC provider."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs GitHub Actions can deploy to."
  type        = list(string)
  default     = []
}

variable "cloudfront_distribution_arns" {
  description = "CloudFront distribution ARNs GitHub Actions can invalidate."
  type        = list(string)
  default     = ["*"]
}

variable "deployment_state_resource_arns" {
  description = "Terraform backend S3 and DynamoDB resource ARNs for CI state access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
