locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow public HTTP and HTTPS ingress to the ALB."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "Public HTTP access."
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_http_cidrs
  ipv6_cidr_blocks  = var.allowed_http_ipv6_cidrs
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "Public HTTPS access."
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_http_cidrs
  ipv6_cidr_blocks  = var.allowed_http_ipv6_cidrs
}

resource "aws_security_group_rule" "alb_egress_app" {
  for_each = toset(var.application_ports)

  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  description              = "Forward traffic to application targets."
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Allow ALB and internal application traffic."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  for_each = toset(var.application_ports)

  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  description              = "Application traffic from ALB."
  from_port                = each.value
  to_port                  = each.value
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "app_ingress_k3s_api" {
  count = var.enable_k3s_api_access ? 1 : 0

  type              = "ingress"
  security_group_id = aws_security_group.app.id
  description       = "Restricted k3s API access."
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = var.k3s_api_allowed_cidrs
}

resource "aws_security_group_rule" "app_self" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  description              = "Internal service-to-service traffic."
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.app.id
  description       = "Outbound application traffic through NAT or VPC endpoints."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidrs
}

resource "aws_security_group" "eks_cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "EKS cluster control plane security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-eks-cluster-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_from_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Allow worker and admin traffic to Kubernetes API."
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "eks_cluster_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.eks_cluster.id
  description       = "EKS control plane egress."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidrs
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow PostgreSQL from application workloads only."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  description              = "PostgreSQL from application workloads."
  from_port                = var.postgres_port
  to_port                  = var.postgres_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.rds.id
  description       = "RDS egress for managed service operations."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidrs
}

resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-redis-sg"
  description = "Allow Redis from application workloads only."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "redis_ingress_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  description              = "Redis from application workloads."
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "redis_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.redis.id
  description       = "Redis egress for managed service operations."
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidrs
}
