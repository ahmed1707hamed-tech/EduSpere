locals {
  name = "${var.name_prefix}-redis"

  common_tags = merge(
    var.tags,
    {
      Name    = local.name
      Module  = "redis"
      Service = "elasticache"
    },
  )
}

resource "random_password" "auth_token" {
  count = var.transit_encryption_enabled ? 1 : 0

  length           = 32
  special          = false
  override_special = ""
}

resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.name_prefix}-redis-subnet-group"
  description = "Private subnet group for ${local.name}"
  subnet_ids  = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-redis-subnet-group"
  })
}

resource "aws_elasticache_parameter_group" "this" {
  name        = "${var.name_prefix}-redis7"
  family      = "redis7"
  description = "Redis 7 parameter group for ${var.name_prefix}"

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-redis7"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.name
  description          = "Redis replication group for ${var.name_prefix}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.this.name

  num_cache_clusters = var.num_cache_clusters

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.security_group_ids

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? random_password.auth_token[0].result : null

  automatic_failover_enabled = var.automatic_failover_enabled && var.num_cache_clusters >= 2
  multi_az_enabled           = var.automatic_failover_enabled && var.num_cache_clusters >= 2

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  auto_minor_version_upgrade = true
  apply_immediately          = false

  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "redis_auth" {
  count = var.transit_encryption_enabled ? 1 : 0

  name                    = "${var.name_prefix}/redis/auth-token"
  description             = "Redis AUTH token for ${local.name}"
  recovery_window_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-redis-auth-token"
  })
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  count = var.transit_encryption_enabled ? 1 : 0

  secret_id = aws_secretsmanager_secret.redis_auth[0].id

  secret_string = jsonencode({
    auth_token  = random_password.auth_token[0].result
    host        = aws_elasticache_replication_group.this.primary_endpoint_address
    port        = var.port
    reader_host = aws_elasticache_replication_group.this.reader_endpoint_address
  })
}
