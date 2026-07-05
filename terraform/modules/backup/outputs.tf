output "backup_vault_id" {
  description = "ID of the AWS Backup vault."
  value       = aws_backup_vault.this.id
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault."
  value       = aws_backup_vault.this.arn
}

output "backup_vault_name" {
  description = "Name of the AWS Backup vault."
  value       = aws_backup_vault.this.name
}

output "backup_plan_id" {
  description = "ID of the AWS Backup plan."
  value       = aws_backup_plan.this.id
}

output "backup_plan_arn" {
  description = "ARN of the AWS Backup plan."
  value       = aws_backup_plan.this.arn
}

output "backup_selection_id" {
  description = "ID of the RDS backup selection."
  value       = aws_backup_selection.rds.id
}

output "backup_iam_role_arn" {
  description = "IAM role ARN used by AWS Backup."
  value       = local.backup_role_arn
}
