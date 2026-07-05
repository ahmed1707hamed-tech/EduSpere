output "rds_key_id" {
  description = "ID of the RDS KMS key."
  value       = aws_kms_key.rds.key_id
}

output "rds_key_arn" {
  description = "ARN of the RDS KMS key."
  value       = aws_kms_key.rds.arn
}

output "rds_key_alias" {
  description = "Alias of the RDS KMS key."
  value       = aws_kms_alias.rds.name
}

output "s3_key_id" {
  description = "ID of the S3 KMS key."
  value       = aws_kms_key.s3.key_id
}

output "s3_key_arn" {
  description = "ARN of the S3 KMS key."
  value       = aws_kms_key.s3.arn
}

output "s3_key_alias" {
  description = "Alias of the S3 KMS key."
  value       = aws_kms_alias.s3.name
}

output "secrets_key_id" {
  description = "ID of the Secrets Manager KMS key."
  value       = aws_kms_key.secrets.key_id
}

output "secrets_key_arn" {
  description = "ARN of the Secrets Manager KMS key."
  value       = aws_kms_key.secrets.arn
}

output "secrets_key_alias" {
  description = "Alias of the Secrets Manager KMS key."
  value       = aws_kms_alias.secrets.name
}

output "logs_key_id" {
  description = "ID of the CloudWatch Logs KMS key."
  value       = aws_kms_key.logs.key_id
}

output "logs_key_arn" {
  description = "ARN of the CloudWatch Logs KMS key."
  value       = aws_kms_key.logs.arn
}

output "logs_key_alias" {
  description = "Alias of the CloudWatch Logs KMS key."
  value       = aws_kms_alias.logs.name
}

output "key_arns" {
  description = "Map of KMS key purposes to ARNs."
  value = {
    rds     = aws_kms_key.rds.arn
    s3      = aws_kms_key.s3.arn
    secrets = aws_kms_key.secrets.arn
    logs    = aws_kms_key.logs.arn
  }
}
