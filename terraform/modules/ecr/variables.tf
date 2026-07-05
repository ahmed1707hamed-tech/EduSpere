variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "repository_names" {
  description = "ECR repository names."
  type        = list(string)
  default = [
    "auth-service",
    "course-service",
    "content-service",
    "quiz-service",
    "notification-service",
    "frontend"
  ]
}

variable "repository_prefix" {
  description = "Prefix applied to ECR repository names."
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability."
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable ECR image scanning on push."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Force delete repositories with images."
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Maximum number of images retained per repository."
  type        = number
  default     = 50
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
