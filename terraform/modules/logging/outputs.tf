output "logs_kms_key_arn" {
  description = "Logging KMS key ARN."
  value       = aws_kms_key.logs.arn
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names."
  value       = { for key, group in aws_cloudwatch_log_group.this : key => group.name }
}

output "cloudwatch_log_group_arns" {
  description = "CloudWatch log group ARNs."
  value       = { for key, group in aws_cloudwatch_log_group.this : key => group.arn }
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN."
  value       = aws_cloudtrail.this.arn
}

output "cloudtrail_bucket_id" {
  description = "CloudTrail bucket ID."
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_bucket_domain_name" {
  description = "CloudTrail bucket regional domain name."
  value       = aws_s3_bucket.cloudtrail.bucket_regional_domain_name
}

output "cloudtrail_role_arn" {
  description = "CloudTrail CloudWatch Logs role ARN."
  value       = aws_iam_role.cloudtrail.arn
}

output "vpc_flow_log_id" {
  description = "VPC Flow Log ID."
  value       = aws_flow_log.vpc.id
}
