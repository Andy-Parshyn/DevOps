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

