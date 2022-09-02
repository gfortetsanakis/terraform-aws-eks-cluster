resource "aws_iam_role" "eks_cluster" {
  for_each = { controlplane_role = "eks.amazonaws.com", worker_role = "ec2.amazonaws.com" }
  name     = "eks-${each.key}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = each.value
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster["controlplane_role"].name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster["worker_role"].name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster["worker_role"].name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster["worker_role"].name
}

resource "aws_eks_cluster" "test_cluster" {
  name     = "test_cluster"
  role_arn = aws_iam_role.eks_cluster["controlplane_role"].arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy
  ]
}

resource "aws_key_pair" "eks_worker_nodes_key" {
  key_name   = "eks-worker-nodes"
  public_key = file(var.eks_worker_nodes_key_path)
}

resource "aws_eks_node_group" "eks_group" {
  for_each        = var.eks_node_groups
  cluster_name    = aws_eks_cluster.test_cluster.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks_cluster["worker_role"].arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size
  instance_types = each.value.instance_types

  update_config {
    max_unavailable = 1
  }

  dynamic "remote_access" {
    for_each = [
      for rule in local.eks_remote_access : rule
      if length(rule["security_groups"]) != 0
    ]
    content {
      ec2_ssh_key               = aws_key_pair.eks_worker_nodes_key.key_name
      source_security_group_ids = remote_access.value.security_groups
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.test_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.test_cluster.identity.0.oidc.0.issuer
}

resource "aws_security_group_rule" "kubectl_allow_security_group" {
  count                    = var.kubectl_allowed_security_group != "" ? 1 : 0
  description              = "Allow connection to kubernetes API from security group ${var.kubectl_allowed_security_group}."
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = var.kubectl_allowed_security_group
  type                     = "ingress"
}

resource "aws_security_group_rule" "kubectl_allow_cidr_blocks" {
  count             = length(var.kubectl_allowed_cidr_blocks) != 0 ? 1 : 0
  description       = "Allow connection to kubernetes API from the cidr blocks ${var.kubectl_allowed_cidr_blocks}."
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
  cidr_blocks       = var.kubectl_allowed_cidr_blocks
  type              = "ingress"
}