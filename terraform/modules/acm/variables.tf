variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "domain_name" {
  description = "Primary certificate domain name."
  type        = string
}

variable "subject_alternative_names" {
  description = "Certificate subject alternative names."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID used for DNS validation."
  type        = string
}

variable "validation_record_ttl" {
  description = "TTL for ACM validation records."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
