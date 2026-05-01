output "s3_bucket_name" {
  value = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# Jenkins
output "jenkins_url" {
  value = module.jenkins.jenkins_url
}

output "jenkins_admin_password" {
  value = module.jenkins.admin_password_command
}

# Argo CD
output "argocd_url" {
  value = module.argo_cd.argocd_url
}

output "argocd_admin_password" {
  value = module.argo_cd.argocd_admin_password
}