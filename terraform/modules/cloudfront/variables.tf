variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "aliases" {
  description = "CloudFront alternate domain names."
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront."
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used as the dynamic application origin."
  type        = string
}

variable "alb_origin_protocol_policy" {
  description = "Origin protocol policy for the ALB origin."
  type        = string
  default     = "https-only"
}

variable "s3_origins" {
  description = "S3 origins for static course, material, and certificate content."
  type = map(object({
    domain_name  = string
    bucket_id    = string
    bucket_arn   = string
    path_pattern = string
  }))
}

variable "is_ipv6_enabled" {
  description = "Enable IPv6 for CloudFront."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"
}

variable "default_root_object" {
  description = "Default root object."
  type        = string
  default     = "index.html"
}

variable "web_acl_id" {
  description = "Optional AWS WAF web ACL ID."
  type        = string
  default     = null
}

variable "alb_forwarded_headers" {
  description = "Headers forwarded to the ALB origin."
  type        = list(string)
  default     = ["Authorization", "CloudFront-Forwarded-Proto", "Host"]
}

variable "alb_default_ttl" {
  description = "Default TTL for ALB responses."
  type        = number
  default     = 0
}

variable "alb_max_ttl" {
  description = "Maximum TTL for ALB responses."
  type        = number
  default     = 60
}

variable "s3_min_ttl" {
  description = "Minimum TTL for S3 origins."
  type        = number
  default     = 0
}

variable "s3_default_ttl" {
  description = "Default TTL for S3 origins."
  type        = number
  default     = 3600
}

variable "s3_max_ttl" {
  description = "Maximum TTL for S3 origins."
  type        = number
  default     = 86400
}

variable "geo_restriction_type" {
  description = "CloudFront geo restriction type."
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "CloudFront geo restriction locations."
  type        = list(string)
  default     = []
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "logging_bucket_domain_name" {
  description = "S3 bucket domain name for CloudFront access logs."
  type        = string
}

variable "logging_prefix" {
  description = "CloudFront logging prefix."
  type        = string
  default     = "cloudfront/"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
