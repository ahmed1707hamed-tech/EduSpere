output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  description = "EKS IAM OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "node_group_arn" {
  description = "EKS managed node group ARN."
  value       = aws_eks_node_group.this.arn
}

output "cluster_security_group_id" {
  description = "EKS generated cluster security group ID."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_log_group_name" {
  description = "EKS control plane log group name."
  value       = aws_cloudwatch_log_group.cluster.name
}
