variable "eks_cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Endpoint EKS кластера"
  type        = string
}

variable "eks_cluster_ca" {
  description = "Certificate Authority (base64)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace для Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Версія Jenkins Helm chart"
  type        = string
  default     = "5.8.3"
}

variable "ecr_repository_url" {
  description = "URL ECR репозиторію (для Kaniko)"
  type        = string
}

variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "eu-central-1"
}
