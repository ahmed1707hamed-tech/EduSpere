output "hosted_zone_id" {
  description = "Route53 hosted zone ID."
  value       = local.zone_id
}

output "hosted_zone_name_servers" {
  description = "Route53 hosted zone name servers."
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].name_servers : []
}

output "root_alias_fqdn" {
  description = "Root alias record FQDN."
  value       = try(aws_route53_record.root_alias[0].fqdn, null)
}

output "www_alias_fqdn" {
  description = "www alias record FQDN."
  value       = try(aws_route53_record.www_alias[0].fqdn, null)
}
