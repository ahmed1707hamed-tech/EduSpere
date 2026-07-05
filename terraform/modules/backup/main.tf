data "aws_partition" "current" {}

locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  backup_role_arn = coalesce(var.iam_role_arn, aws_iam_role.backup[0].arn)

  use_arn_selection  = length(var.rds_resource_arns) > 0
  use_tag_selection  = !local.use_arn_selection && length(var.rds_selection_tags) > 0
  create_backup_role = var.iam_role_arn == null
}

#############################
# IAM Role for AWS Backup
#############################

resource "aws_iam_role" "backup" {
  count = local.create_backup_role ? 1 : 0

  name = "${local.name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  count = local.create_backup_role ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  count = local.create_backup_role ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

#############################
# Backup Vault
#############################

resource "aws_backup_vault" "this" {
  name          = "${local.name}-vault"
  kms_key_arn   = var.kms_key_arn
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = "${local.name}-vault"
  })
}

#############################
# Backup Plan
#############################

resource "aws_backup_plan" "this" {
  name = "${local.name}-plan"

  rule {
    rule_name                = "daily-rds-backup"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.backup_schedule
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window
    enable_continuous_backup = var.enable_continuous_backup

    lifecycle {
      delete_after = var.backup_delete_after_days
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-plan"
  })
}

#############################
# RDS Backup Selection
#############################

resource "aws_backup_selection" "rds" {
  name         = "${local.name}-rds-selection"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = local.backup_role_arn

  resources = local.use_arn_selection ? var.rds_resource_arns : ["*"]

  dynamic "selection_tag" {
    for_each = local.use_tag_selection ? [1] : []

    content {
      type  = "STRINGEQUALS"
      key   = keys(var.rds_selection_tags)[0]
      value = values(var.rds_selection_tags)[0]
    }
  }

  dynamic "condition" {
    for_each = local.use_arn_selection || local.use_tag_selection ? [] : [1]

    content {
      string_equals {
        key   = "aws:ResourceTag/Project"
        value = var.project_name
      }
    }
  }
}
