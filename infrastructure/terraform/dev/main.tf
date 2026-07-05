module "vpc" {
  source = "../modules/vpc"

  project_name = var.project_name
  region       = var.region

  vpc_cidr = var.vpc_cidr

  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr

  private_app_subnet_1_cidr = var.private_app_subnet_1_cidr
  private_app_subnet_2_cidr = var.private_app_subnet_2_cidr

  private_db_subnet_1_cidr = var.private_db_subnet_1_cidr
  private_db_subnet_2_cidr = var.private_db_subnet_2_cidr
}

module "security_groups" {
  source            = "../modules/security-groups"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  admin_cidr_blocks = var.admin_cidr_blocks
}

module "ec2" {
  source = "../modules/ec2"

  project_name = var.project_name
  tags         = var.tags

  subnet_id                 = module.vpc.public_subnet_ids[0]
  security_group_id         = module.security_groups.eks_nodes_sg_id
  iam_instance_profile_name = var.ec2_iam_instance_profile_name
  key_name                  = var.ec2_key_name
  instance_type             = var.ec2_instance_type

  root_volume_size_gb        = 20
  root_volume_type           = "gp3"
  enable_detailed_monitoring = true
}

module "rds" {
  source = "../modules/rds"

  project_name = var.project_name
  tags         = var.tags

  db_subnet_ids     = module.vpc.private_db_subnet_ids
  security_group_id = module.security_groups.eks_nodes_sg_id

  db_name                 = "edusphere"
  username                = var.rds_username
  password                = var.rds_password
  instance_class          = "db.t3.micro"
  allocated_storage_gb    = 20
  storage_type            = "gp3"
  multi_az                = var.rds_multi_az
  backup_retention_period = 7
  deletion_protection     = var.rds_deletion_protection
}

module "s3" {
  source = "../modules/s3"

  project_name = var.project_name
  tags         = var.tags

  bucket_prefix         = var.bucket_prefix
  lifecycle_expire_days = 0
}

module "alb" {
  source = "../modules/alb"

  project_name = var.project_name
  tags         = var.tags

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id

  target_instance_id = module.ec2.instance_id
  target_port        = 80
  health_check_path  = "/"
}

module "monitoring" {
  source = "../modules/monitoring"

  project_name = var.project_name
  tags         = var.tags

  instance_id           = module.ec2.instance_id
  alarm_email_endpoints = var.alarm_email_endpoints
}

