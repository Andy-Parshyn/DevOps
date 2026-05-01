variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "61.3.2"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
