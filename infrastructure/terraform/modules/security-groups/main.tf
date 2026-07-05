resource "aws_security_group" "alb" {

  name        = "${var.project_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "${var.project_name}-alb-sg"

  }

}
resource "aws_security_group" "eks_nodes" {

  name = "${var.project_name}-eks-sg"

  vpc_id = var.vpc_id

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    security_groups = [

      aws_security_group.alb.id

    ]

  }

  ingress {

    from_port = 443

    to_port = 443

    protocol = "tcp"

    security_groups = [

      aws_security_group.alb.id

    ]

  }

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = var.admin_cidr_blocks

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}