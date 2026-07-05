locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "monitoring"
    },
    var.tags
  )

  log_group = length(trimspace(var.log_group_name)) > 0 ? var.log_group_name : "/edusphere/${var.project_name}"
}

# SNS topic for alarms.
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.alarm_email_endpoints)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
}

# Central log group for app/system logs (agent-based shipping can be added later).
resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group
  retention_in_days = 30
  tags              = local.tags
}

# CPU utilization alarm.
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = local.tags
}

# EC2 instance status check alarm.
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.project_name}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = local.tags
}

