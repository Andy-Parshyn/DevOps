output "cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint EKS кластера"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority для кластера"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_name" {
  description = "Назва Node Group"
  value       = aws_eks_node_group.main.node_group_name
}

output "oidc_provider_arn" {
  description = "ARN OIDC провайдера для IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}