output "s3_kms_key_arn" {
  description = "S3 KMS key ARN."
  value       = aws_kms_key.s3.arn
}

output "bucket_ids" {
  description = "S3 bucket IDs by logical name."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.id }
}

output "bucket_arns" {
  description = "S3 bucket ARNs by logical name."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.arn }
}

output "bucket_domain_names" {
  description = "S3 bucket regional domain names by logical name."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.bucket_regional_domain_name }
}

output "terraform_lock_table_name" {
  description = "Terraform state lock table name."
  value       = try(aws_dynamodb_table.terraform_locks[0].name, null)
}

output "terraform_lock_table_arn" {
  description = "Terraform state lock table ARN."
  value       = try(aws_dynamodb_table.terraform_locks[0].arn, null)
}
