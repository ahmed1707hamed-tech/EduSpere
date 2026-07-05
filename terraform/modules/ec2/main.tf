locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

data "aws_ami" "amazon_linux" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "k3s" {
  count = var.instance_count

  ami                         = coalesce(var.ami_id, data.aws_ami.amazon_linux[0].id)
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false
  user_data                   = var.user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-k3s-root-${count.index + 1}"
    })
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring = var.enable_detailed_monitoring

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k3s-${count.index + 1}"
    Role = "k3s"
  })

  lifecycle {
    create_before_destroy = true
  }
}
