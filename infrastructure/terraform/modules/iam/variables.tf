variable "project_name" {
  type = string
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "enable_github_actions_oidc" {
  description = "Whether to create a GitHub Actions OIDC provider + role in this module."
  type        = bool
  default     = false
}

variable "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider. If empty, the module will create one."
  type        = string
  default     = ""
}

variable "github_org" {
  description = "GitHub organization/user for OIDC trust (e.g., 'EduSphereOrg')."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_github_actions_oidc == false || length(trim(var.github_org)) > 0
    error_message = "When enable_github_actions_oidc is true, github_org must be set."
  }
}

variable "github_repo" {
  description = "GitHub repository name for OIDC trust (e.g., 'EduSphere')."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_github_actions_oidc == false || length(trim(var.github_repo)) > 0
    error_message = "When enable_github_actions_oidc is true, github_repo must be set."
  }
}

variable "github_ref_patterns" {
  description = "Allowed GitHub ref patterns (sub claim). Examples: 'ref:refs/heads/main', 'ref:refs/tags/*'."
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}

variable "github_role_policy_arns" {
  description = "Policy ARNs to attach to the GitHub Actions role."
  type        = list(string)
  default     = []
}

