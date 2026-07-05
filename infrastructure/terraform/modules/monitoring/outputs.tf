output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "status_check_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.status_check_failed.arn
}

