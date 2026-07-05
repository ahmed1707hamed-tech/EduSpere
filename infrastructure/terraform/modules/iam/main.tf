locals {
  tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
      Module  = "iam"
    },
    var.tags
  )

  # GitHub OIDC subject patterns (only used when GitHub OIDC is enabled).
  github_subjects = var.enable_github_actions_oidc ? [
    for ref in var.github_ref_patterns : "repo:${var.github_org}/${var.github_repo}:${ref}"
  ] : []
}

data "aws_caller_identity" "current" {}

# GitHub Actions publishes OIDC tokens signed by certificates at this URL.
# We use the TLS provider to fetch the SHA1 thumbprint for the IAM OIDC provider.
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.enable_github_actions_oidc && var.github_oidc_provider_arn == "" ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  tags            = local.tags
}

locals {
  github_provider_arn = var.enable_github_actions_oidc ? (
    var.github_oidc_provider_arn != "" ? var.github_oidc_provider_arn : aws_iam_openid_connect_provider.github[0].arn
  ) : null
}

############################
# EC2 role (for k3s / bastion style instances)
############################

data "aws_iam_policy_document" "ec2_assume" {
  # Allow EC2 instances to assume this role.
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "ec2" {
  # Instance profile required to attach the role to EC2 instances.
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  # Least-privilege managed policy to enable AWS Systems Manager Session Manager.
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################
# EKS cluster role
############################

resource "aws_iam_role" "eks_cluster" {
  # Role assumed by the EKS control plane.
  name               = "${var.project_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "eks_cluster_assume" {
  # Allow EKS to assume the cluster role.
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  # Required for EKS cluster management.
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  # Required for managing ENIs and VPC resources used by EKS.
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

############################
# EKS node group role
############################

data "aws_iam_policy_document" "eks_nodes_assume" {
  # Allow EC2 instances (EKS worker nodes) to assume the node role.
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  # Role assumed by EKS managed node group instances.
  name               = "${var.project_name}-eks-nodes-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_nodes_worker" {
  # Required for worker nodes to join the cluster and communicate with the control plane.
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni" {
  # Required for VPC CNI networking.
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr_ro" {
  # Allows nodes to pull images from ECR.
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# GitHub Actions OIDC role
############################

data "aws_iam_policy_document" "github_assume" {
  # Trust policy restricting role assumption to a specific repo + refs via OIDC.
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = var.enable_github_actions_oidc ? [local.github_provider_arn] : []
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  count              = var.enable_github_actions_oidc ? 1 : 0
  name               = "${var.project_name}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "github_attach" {
  for_each   = toset(var.github_role_policy_arns)
  role       = aws_iam_role.github_actions[0].name
  policy_arn = each.value
}

