output "sns_topic_arn" {
  description = "SNS alert topic ARN."
  value       = aws_sns_topic.alerts.arn
}

output "backup_kms_key_arn" {
  description = "AWS Backup KMS key ARN."
  value       = aws_kms_key.backup.arn
}

output "backup_vault_arn" {
  description = "AWS Backup vault ARN."
  value       = aws_backup_vault.this.arn
}

output "backup_plan_id" {
  description = "AWS Backup plan ID."
  value       = aws_backup_plan.this.id
}

output "alarm_names" {
  description = "Created CloudWatch alarm names."
  value = concat(
    [aws_cloudwatch_metric_alarm.alb_5xx.alarm_name],
    [aws_cloudwatch_metric_alarm.rds_cpu.alarm_name],
    [aws_cloudwatch_metric_alarm.redis_cpu.alarm_name],
    [for alarm in aws_cloudwatch_metric_alarm.ec2_status : alarm.alarm_name]
  )
}
