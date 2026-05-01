# Namespace для Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# Встановлення Argo CD через Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  timeout = 600
  wait    = true

  values = [
    file("${path.module}/values.yaml")
  ]
}

# Argo CD Application — стежить за django-app Helm chart
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = kubernetes_namespace.argocd.metadata[0].name
  chart     = "${path.module}/charts"

  values = [
    templatefile("${path.module}/charts/values.yaml", {
      git_repo_url     = var.git_repo_url
      app_namespace    = var.app_namespace
      argocd_namespace = var.namespace
    })
  ]

  depends_on = [helm_release.argocd]
}
