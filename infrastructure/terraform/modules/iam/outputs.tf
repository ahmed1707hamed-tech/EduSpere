output "ec2_role_name" {
  value = aws_iam_role.ec2.name
}

output "ec2_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "github_actions_role_arn" {
  value = try(aws_iam_role.github_actions[0].arn, null)
}

output "github_oidc_provider_arn" {
  value = local.github_provider_arn
}

