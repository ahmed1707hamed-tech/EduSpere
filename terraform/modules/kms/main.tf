data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "kms"
    },
    var.tags
  )

  kms_key_policy = {
    rds = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        [
          {
            Sid       = "EnableRootPermissions"
            Effect    = "Allow"
            Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
            Action    = "kms:*"
            Resource  = "*"
          },
          {
            Sid    = "AllowRDSServiceUse"
            Effect = "Allow"
            Principal = {
              Service = "rds.amazonaws.com"
            }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:CreateGrant",
              "kms:DescribeKey"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "kms:CallerAccount" = local.account_id
              }
            }
          }
        ],
        length(var.rds_admin_role_arns) > 0 ? [
          {
            Sid       = "AllowRDSAdminRoles"
            Effect    = "Allow"
            Principal = { AWS = var.rds_admin_role_arns }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
          }
        ] : []
      )
    })

    s3 = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        [
          {
            Sid       = "EnableRootPermissions"
            Effect    = "Allow"
            Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
            Action    = "kms:*"
            Resource  = "*"
          },
          {
            Sid    = "AllowS3ServiceUse"
            Effect = "Allow"
            Principal = {
              Service = "s3.amazonaws.com"
            }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "kms:CallerAccount" = local.account_id
              }
            }
          }
        ],
        length(var.s3_admin_role_arns) > 0 ? [
          {
            Sid       = "AllowS3AdminRoles"
            Effect    = "Allow"
            Principal = { AWS = var.s3_admin_role_arns }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
          }
        ] : []
      )
    })

    secrets = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        [
          {
            Sid       = "EnableRootPermissions"
            Effect    = "Allow"
            Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
            Action    = "kms:*"
            Resource  = "*"
          },
          {
            Sid    = "AllowSecretsManagerUse"
            Effect = "Allow"
            Principal = {
              Service = "secretsmanager.amazonaws.com"
            }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:CreateGrant",
              "kms:DescribeKey"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "kms:CallerAccount" = local.account_id
              }
            }
          }
        ],
        length(var.secrets_admin_role_arns) > 0 ? [
          {
            Sid       = "AllowSecretsAdminRoles"
            Effect    = "Allow"
            Principal = { AWS = var.secrets_admin_role_arns }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
          }
        ] : []
      )
    })

    logs = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        [
          {
            Sid       = "EnableRootPermissions"
            Effect    = "Allow"
            Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
            Action    = "kms:*"
            Resource  = "*"
          },
          {
            Sid    = "AllowCloudWatchLogsUse"
            Effect = "Allow"
            Principal = {
              Service = "logs.${local.region}.amazonaws.com"
            }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:CreateGrant",
              "kms:DescribeKey"
            ]
            Resource = "*"
            Condition = {
              ArnLike = {
                "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.region}:${local.account_id}:*"
              }
            }
          }
        ],
        length(var.logs_admin_role_arns) > 0 ? [
          {
            Sid       = "AllowLogsAdminRoles"
            Effect    = "Allow"
            Principal = { AWS = var.logs_admin_role_arns }
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
          }
        ] : []
      )
    })
  }
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption (${local.name_prefix})"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = local.kms_key_policy.rds

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-rds-kms"
    Purpose = "rds"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${local.name_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption (${local.name_prefix})"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = local.kms_key_policy.s3

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-s3-kms"
    Purpose = "s3"
  })
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${local.name_prefix}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager (${local.name_prefix})"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = local.kms_key_policy.secrets

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-secrets-kms"
    Purpose = "secrets"
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs (${local.name_prefix})"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = local.kms_key_policy.logs

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-logs-kms"
    Purpose = "logs"
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${local.name_prefix}-logs"
  target_key_id = aws_kms_key.logs.key_id
}
