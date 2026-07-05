output "replication_group_id" {
  description = "ElastiCache replication group ID."
  value       = aws_elasticache_replication_group.this.id
}

output "replication_group_arn" {
  description = "ElastiCache replication group ARN."
  value       = aws_elasticache_replication_group.this.arn
}

output "primary_endpoint_address" {
  description = "Primary Redis endpoint address."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader Redis endpoint address."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "configuration_endpoint_address" {
  description = "Configuration endpoint for cluster mode (null for non-cluster mode)."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "port" {
  description = "Redis port."
  value       = aws_elasticache_replication_group.this.port
}

output "subnet_group_id" {
  description = "ElastiCache subnet group name."
  value       = aws_elasticache_subnet_group.this.id
}

output "subnet_group_arn" {
  description = "ElastiCache subnet group ARN."
  value       = aws_elasticache_subnet_group.this.arn
}

output "parameter_group_id" {
  description = "ElastiCache parameter group ID."
  value       = aws_elasticache_parameter_group.this.id
}

output "parameter_group_arn" {
  description = "ElastiCache parameter group ARN."
  value       = aws_elasticache_parameter_group.this.arn
}

output "member_cluster_ids" {
  description = "IDs of cache clusters in the replication group."
  value       = aws_elasticache_replication_group.this.member_clusters
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager ARN for Redis AUTH token (null when transit encryption is disabled)."
  value       = try(aws_secretsmanager_secret.redis_auth[0].arn, null)
}
