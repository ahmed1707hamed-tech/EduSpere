project_name = "edusphere-dev"
region       = "us-east-1"

vpc_cidr = "10.10.0.0/16"

public_subnet_1_cidr = "10.10.1.0/24"
public_subnet_2_cidr = "10.10.2.0/24"

private_app_subnet_1_cidr = "10.10.11.0/24"
private_app_subnet_2_cidr = "10.10.12.0/24"

private_db_subnet_1_cidr = "10.10.21.0/24"
private_db_subnet_2_cidr = "10.10.22.0/24"

admin_cidr_blocks = []

tags = {
  Environment = "dev"
  Project     = "edusphere"
}

ec2_key_name                  = "devops-key"
ec2_iam_instance_profile_name = ""
ec2_instance_type             = "t3.micro"

rds_username            = "postgres"
rds_password            = "change-me"
rds_multi_az            = false
rds_deletion_protection = false

bucket_prefix = "edusphere-dev"

alarm_email_endpoints = []

