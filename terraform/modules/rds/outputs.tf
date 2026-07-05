output "database_kms_key_arn" {
  description = "Database KMS key ARN."
  value       = aws_kms_key.database.arn
}

output "db_instance_id" {
  description = "RDS PostgreSQL instance ID."
  value       = aws_db_instance.postgres.id
}

output "db_instance_arn" {
  description = "RDS PostgreSQL instance ARN."
  value       = aws_db_instance.postgres.arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.postgres.endpoint
}

output "db_address" {
  description = "RDS PostgreSQL address."
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.postgres.port
}

output "db_subnet_group_name" {
  description = "RDS subnet group name."
  value       = aws_db_subnet_group.postgres.name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for PostgreSQL credentials."
  value       = aws_secretsmanager_secret.db.arn
}

output "redis_replication_group_id" {
  description = "Redis replication group ID."
  value       = aws_elasticache_replication_group.redis.id
}

output "redis_replication_group_arn" {
  description = "Redis replication group ARN."
  value       = aws_elasticache_replication_group.redis.arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint."
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_secret_arn" {
  description = "Secrets Manager ARN for Redis auth token."
  value       = aws_secretsmanager_secret.redis.arn
}
