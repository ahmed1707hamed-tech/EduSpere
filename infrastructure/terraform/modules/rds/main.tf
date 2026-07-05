locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "rds"
    },
    var.tags
  )
}

# Subnet group for private database deployment.
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.tags, { Name = "${var.project_name}-db-subnets" })
}

# PostgreSQL 16 parameter group.
resource "aws_db_parameter_group" "this" {
  name   = "${var.project_name}-postgres16"
  family = "postgres16"

  # Enable reasonable logging defaults.
  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  tags = merge(local.tags, { Name = "${var.project_name}-postgres16" })
}

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.username
  password = var.password

  allocated_storage = var.allocated_storage_gb
  storage_type      = var.storage_type
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  parameter_group_name = aws_db_parameter_group.this.name

  backup_retention_period = 0
  copy_tags_to_snapshot   = true
  multi_az                = var.multi_az

  deletion_protection = false

  skip_final_snapshot = var.skip_final_snapshot

  # Avoid accidental replacement on password rotation plans.
  lifecycle {
    ignore_changes = [password]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-postgres" })
}