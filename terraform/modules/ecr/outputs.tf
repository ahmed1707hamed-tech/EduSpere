output "ecr_kms_key_arn" {
  description = "ECR KMS key ARN."
  value       = aws_kms_key.ecr.arn
}

output "repository_names" {
  description = "ECR repository names by service."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.name }
}

output "repository_arns" {
  description = "ECR repository ARNs by service."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.arn }
}

output "repository_urls" {
  description = "ECR repository URLs by service."
  value       = { for key, repo in aws_ecr_repository.this : key => repo.repository_url }
}
