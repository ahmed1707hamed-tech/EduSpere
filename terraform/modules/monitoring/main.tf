locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_sns_topic" "alerts" {
  name              = "${local.name_prefix}-alerts"
  kms_master_key_id = var.sns_kms_key_id

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alert_email_endpoints)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "ALB is returning elevated 5xx responses."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "RDS CPU utilization is elevated."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${local.name_prefix}-redis-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.redis_cpu_threshold
  alarm_description   = "Redis CPU utilization is elevated."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ReplicationGroupId = var.redis_replication_group_id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  for_each = toset(var.ec2_instance_ids)

  alarm_name          = "${local.name_prefix}-ec2-status-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 instance status check failed."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = each.value
  }

  tags = local.common_tags
}

resource "aws_kms_key" "backup" {
  description             = "KMS key for ${local.name_prefix} AWS Backup vault."
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-kms"
  })
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${local.name_prefix}-backup"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_backup_vault" "this" {
  name        = "${local.name_prefix}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn

  tags = local.common_tags
}

resource "aws_backup_plan" "this" {
  name = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.backup_schedule
    start_window      = var.backup_start_window_minutes
    completion_window = var.backup_completion_window_minutes

    lifecycle {
      cold_storage_after = var.backup_cold_storage_after_days
      delete_after       = var.backup_delete_after_days
    }
  }

  tags = local.common_tags
}

resource "aws_backup_selection" "this" {
  count = length(var.backup_resource_arns) > 0 ? 1 : 0

  iam_role_arn = var.backup_role_arn
  name         = "${local.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.this.id
  resources    = var.backup_resource_arns
}
