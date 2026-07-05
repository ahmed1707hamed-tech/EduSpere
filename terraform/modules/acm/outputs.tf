output "certificate_arn" {
  description = "Validated ACM certificate ARN."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_name" {
  description = "ACM certificate domain name."
  value       = aws_acm_certificate.this.domain_name
}

output "validation_record_fqdns" {
  description = "ACM DNS validation record FQDNs."
  value       = [for record in aws_route53_record.validation : record.fqdn]
}
