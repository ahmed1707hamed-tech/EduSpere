locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "random_password" "db" {
  length           = var.db_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "redis" {
  length           = var.redis_auth_token_length
  special          = false
}

resource "aws_kms_key" "database" {
  description             = "KMS key for ${local.name_prefix} database and cache encryption."
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-kms"
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${local.name_prefix}-database"
  target_key_id = aws_kms_key.database.key_id
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${local.name_prefix}/rds/postgres"
  description             = "PostgreSQL credentials for ${local.name_prefix}."
  kms_key_id              = aws_kms_key.database.arn
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = var.db_name
  })
}

resource "aws_secretsmanager_secret" "redis" {
  name                    = "${local.name_prefix}/elasticache/redis"
  description             = "Redis auth token for ${local.name_prefix}."
  kms_key_id              = aws_kms_key.database.arn
  recovery_window_in_days = var.secret_recovery_window_in_days

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    auth_token = local.redis_auth_token
    endpoint   = aws_elasticache_replication_group.redis.primary_endpoint_address
    port       = var.redis_port
  })
}

locals {
  redis_auth_token = coalesce(var.redis_auth_token, random_password.redis.result)
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${local.name_prefix}-postgres-subnets"
  subnet_ids = var.database_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-postgres-subnets"
  })
}

resource "aws_db_parameter_group" "postgres" {
  name        = "${local.name_prefix}-postgres-params"
  family      = var.db_parameter_group_family
  description = "PostgreSQL parameter group for ${local.name_prefix}."

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = local.common_tags
}

resource "aws_db_instance" "postgres" {
  identifier                          = "${local.name_prefix}-postgres"
  engine                              = "postgres"
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  allocated_storage                   = var.db_allocated_storage
  max_allocated_storage               = var.db_max_allocated_storage
  storage_type                        = var.db_storage_type
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.database.arn
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = random_password.db.result
  port                                = var.db_port
  multi_az                            = var.db_multi_az
  publicly_accessible                 = false
  db_subnet_group_name                = aws_db_subnet_group.postgres.name
  vpc_security_group_ids              = var.rds_security_group_ids
  parameter_group_name                = aws_db_parameter_group.postgres.name
  backup_retention_period             = var.db_backup_retention_days
  backup_window                       = var.db_backup_window
  maintenance_window                  = var.db_maintenance_window
  deletion_protection                 = var.db_deletion_protection
  skip_final_snapshot                 = var.db_skip_final_snapshot
  final_snapshot_identifier           = var.db_skip_final_snapshot ? null : "${local.name_prefix}-postgres-final"
  copy_tags_to_snapshot               = true
  enabled_cloudwatch_logs_exports     = var.db_enabled_cloudwatch_logs_exports
  performance_insights_enabled        = var.db_performance_insights_enabled
  performance_insights_kms_key_id     = var.db_performance_insights_enabled ? aws_kms_key.database.arn : null
  iam_database_authentication_enabled = var.db_iam_authentication_enabled
  auto_minor_version_upgrade          = var.db_auto_minor_version_upgrade
  apply_immediately                   = var.db_apply_immediately

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-postgres"
  })
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.name_prefix}-redis-subnets"
  subnet_ids = var.database_subnet_ids

  tags = local.common_tags
}

resource "aws_elasticache_parameter_group" "redis" {
  name        = "${local.name_prefix}-redis-params"
  family      = var.redis_parameter_group_family
  description = "Redis parameter group for ${local.name_prefix}."

  dynamic "parameter" {
    for_each = var.redis_parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.common_tags
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.name_prefix}-redis"
  description                = "Redis replication group for ${local.name_prefix}."
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type
  port                       = var.redis_port
  parameter_group_name       = aws_elasticache_parameter_group.redis.name
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = var.redis_security_group_ids
  num_cache_clusters         = var.redis_node_count
  automatic_failover_enabled = var.redis_node_count > 1 ? var.redis_automatic_failover_enabled : false
  multi_az_enabled           = var.redis_node_count > 1 ? var.redis_multi_az_enabled : false
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = local.redis_auth_token
  kms_key_id                 = aws_kms_key.database.arn
  snapshot_retention_limit   = var.redis_snapshot_retention_days
  snapshot_window            = var.redis_snapshot_window
  maintenance_window         = var.redis_maintenance_window
  auto_minor_version_upgrade = var.redis_auto_minor_version_upgrade
  apply_immediately          = var.redis_apply_immediately

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis"
  })
}
