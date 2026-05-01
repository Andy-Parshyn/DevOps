variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Password for the Grafana admin user"
  type        = string
  sensitive   = true
}
