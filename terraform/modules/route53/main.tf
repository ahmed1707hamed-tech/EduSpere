locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
  zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : var.hosted_zone_id
}

resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0

  name          = var.domain_name
  comment       = "Hosted zone for ${local.name_prefix}."
  force_destroy = var.force_destroy_zone

  tags = merge(local.common_tags, {
    Name = var.domain_name
  })
}

resource "aws_route53_record" "root_alias" {
  count = var.create_alias_records ? 1 : 0

  zone_id = local.zone_id
  name    = var.root_record_name
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "www_alias" {
  count = var.create_www_record ? 1 : 0

  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
