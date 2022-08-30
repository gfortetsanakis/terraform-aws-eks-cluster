output "eks_endpoint" {
  value = aws_eks_cluster.test_cluster.endpoint
}

output "eks_cluster_ca_cert" {
  value = aws_eks_cluster.test_cluster.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = aws_eks_cluster.test_cluster.name
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_cluster_oidc_provider.arn
}

output "openid_connect_provider_url" {
  value = replace(aws_iam_openid_connect_provider.eks_cluster_oidc_provider.url, "https://", "")
}

output "eks_cluster_sg_id" {
  value = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
}