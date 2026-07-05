variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "domain_name" {
  description = "Hosted zone domain name."
  type        = string
}

variable "create_hosted_zone" {
  description = "Create a new public Route53 hosted zone."
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "Existing hosted zone ID when create_hosted_zone is false."
  type        = string
  default     = null
}

variable "force_destroy_zone" {
  description = "Allow hosted zone deletion with records."
  type        = bool
  default     = false
}

variable "create_alias_records" {
  description = "Create the root alias record."
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Create the www alias record."
  type        = bool
  default     = true
}

variable "root_record_name" {
  description = "Root record name."
  type        = string
}

variable "alias_dns_name" {
  description = "Alias target DNS name."
  type        = string
  default     = null
}

variable "alias_zone_id" {
  description = "Alias target hosted zone ID."
  type        = string
  default     = null
}

variable "evaluate_target_health" {
  description = "Evaluate alias target health."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
