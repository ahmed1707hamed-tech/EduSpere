output "ec2_role_name" {
  description = "EC2 IAM role name."
  value       = aws_iam_role.ec2.name
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN."
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name."
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN."
  value       = aws_iam_instance_profile.ec2.arn
}

output "eks_cluster_role_arn" {
  description = "EKS cluster role ARN."
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  description = "EKS node group role ARN."
  value       = aws_iam_role.eks_node_group.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions OIDC role ARN."
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "backup_role_arn" {
  description = "AWS Backup service role ARN."
  value       = aws_iam_role.backup.arn
}

output "flow_logs_role_arn" {
  description = "VPC Flow Logs role ARN."
  value       = aws_iam_role.flow_logs.arn
}
