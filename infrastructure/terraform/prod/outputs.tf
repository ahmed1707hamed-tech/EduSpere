output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  value = module.vpc.private_db_subnet_ids
}

output "alb_sg_id" {
  value = module.security_groups.alb_sg_id
}

output "eks_nodes_sg_id" {
  value = module.security_groups.eks_nodes_sg_id
}

