variable "namespace" {
  description = "Kubernetes namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Argo CD Helm chart"
  type        = string
  default     = "5.55.0"
}

variable "git_repo_url" {
  description = "URL Git репозиторію для Argo CD"
  type        = string
  default     = "https://github.com/Andy-Parshyn/DevOps.git"
}

variable "app_namespace" {
  description = "Target namespace для Django застосунку"
  type        = string
  default     = "default"
}
