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
output "jenkins_url_command" {
  value = module.jenkins.jenkins_url_command
}

output "jenkins_admin_password" {
  value = module.jenkins.admin_password_command
}

# Argo CD
output "argocd_url_command" {
  value = module.argo_cd.argocd_url_command
}

output "argocd_admin_password" {
  value = module.argo_cd.argocd_admin_password
}

# RDS
output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_port" {
  value = module.rds.port
}

output "rds_db_name" {
  value = module.rds.db_name
}