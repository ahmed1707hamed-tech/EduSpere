locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "alb"
    },
    var.tags
  )
}

# Internet-facing Application Load Balancer.
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = var.public_subnet_ids
  security_groups = [var.alb_security_group_id]

  tags = merge(local.tags, { Name = "${var.project_name}-alb" })
}

# Target group registered to the EC2 instance.
resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = merge(local.tags, { Name = "${var.project_name}-tg" })
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_instance_id
  port             = var.target_port
}

# HTTP listener.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

