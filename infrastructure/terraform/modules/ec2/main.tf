locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "ec2"
    },
    var.tags
  )
}

# Latest Ubuntu 22.04 LTS AMI (Jammy) from Canonical.
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "this" {
  # Primary EC2 instance hosting EduSphere runtime (Docker, Nginx, etc.).
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.key_name
  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = var.root_volume_type
    encrypted   = true
  }

  user_data = <<-EOF
    #!/usr/bin/env bash
    set -euo pipefail

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      git \
      jq \
      unzip \
      htop \
      nginx

    # Docker official repo
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update -y
    apt-get install -y --no-install-recommends \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    systemctl enable --now docker
    systemctl enable --now nginx

    # Reduce image size.
    apt-get clean
    rm -rf /var/lib/apt/lists/*
  EOF

  tags = merge(local.tags, { Name = "${var.project_name}-ec2" })
}

