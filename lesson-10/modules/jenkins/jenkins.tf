# Namespace для Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# ServiceAccount для Jenkins agent — потрібен доступ до ECR
resource "kubernetes_service_account" "jenkins_agent" {
  metadata {
    name      = "jenkins-agent"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    annotations = {
      # Для IRSA (IAM Role for Service Account) — додамо пізніше
    }
  }
}

# Helm release — сам Jenkins
resource "helm_release" "jenkins" {
  name       = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  # Таймаут збільшений бо Jenkins важкий
  timeout = 600

  # Чекати поки всі поди будуть Ready
  wait = true

  # Підключаємо кастомні values
  values = [
    templatefile("${path.module}/values.yaml", {
      namespace = var.namespace
    })
  ]

  set_sensitive {
    name  = "controller.admin.password"
    value = var.jenkins_admin_password
  }
}
