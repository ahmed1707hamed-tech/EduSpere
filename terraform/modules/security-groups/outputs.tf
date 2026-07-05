output "alb_security_group_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Application and EC2/EKS node security group ID."
  value       = aws_security_group.app.id
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = aws_security_group.eks_cluster.id
}

output "rds_security_group_id" {
  description = "RDS PostgreSQL security group ID."
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Redis security group ID."
  value       = aws_security_group.redis.id
}
