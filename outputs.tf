output "eks_cluster_properties" {
  type = "map"
  value = {
    eks_cluster_name            = aws_eks_cluster.test_cluster.name
    eks_endpoint                = aws_eks_cluster.test_cluster.endpoint
    eks_cluster_ca_cert         = aws_eks_cluster.test_cluster.certificate_authority[0].data
    openid_connect_provider_arn = aws_iam_openid_connect_provider.eks_cluster_oidc_provider.arn
    openid_connect_provider_url = aws_iam_openid_connect_provider.eks_cluster_oidc_provider.url
    subnet_ids                  = aws_eks_cluster.test_cluster.vpc_config[0].subnet_ids
    eks_cluster_sg_id           = aws_eks_cluster.test_cluster.vpc_config[0].cluster_security_group_id
    vpc_id                      = aws_eks_cluster.test_cluster.vpc_config[0].vpc_id
  }
}