output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_app_subnet_ids" { value = module.vpc.private_app_subnet_ids }
output "private_db_subnet_ids" { value = module.vpc.private_db_subnet_ids }
output "alb_sg_id" { value = module.security_groups.alb_sg_id }
output "eks_nodes_sg_id" { value = module.security_groups.eks_nodes_sg_id }

output "ec2_instance_id" { value = module.ec2.instance_id }
output "ec2_public_ip" { value = module.ec2.public_ip }
output "ec2_private_ip" { value = module.ec2.private_ip }
output "ec2_public_dns" { value = module.ec2.public_dns }

output "rds_endpoint" { value = module.rds.endpoint }
output "rds_port" { value = module.rds.port }
output "rds_arn" { value = module.rds.arn }

output "s3_bucket_names" { value = module.s3.bucket_names }
output "s3_bucket_arns" { value = module.s3.bucket_arns }

output "alb_dns_name" { value = module.alb.alb_dns_name }
output "alb_arn" { value = module.alb.alb_arn }

output "cloudwatch_log_group_name" { value = module.monitoring.log_group_name }
output "alarms_sns_topic_arn" { value = module.monitoring.sns_topic_arn }

