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
      ecr_repository_url = var.ecr_repository_url
      aws_region         = var.aws_region
      namespace          = var.namespace
    })
  ]
}
