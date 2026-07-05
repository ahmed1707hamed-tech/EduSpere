output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_control_ids" {
  description = "CloudFront origin access control IDs."
  value       = { for key, oac in aws_cloudfront_origin_access_control.s3 : key => oac.id }
}
