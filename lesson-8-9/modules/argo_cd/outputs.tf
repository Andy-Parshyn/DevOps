output "argocd_url" {
  description = "Команда для отримання URL Argo CD"
  value       = "kubectl get svc -n ${var.namespace} argocd-argo-cd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_admin_password" {
  description = "Команда для отримання пароля адміністратора Argo CD"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
