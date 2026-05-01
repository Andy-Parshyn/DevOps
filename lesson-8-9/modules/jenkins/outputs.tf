output "jenkins_url" {
  description = "URL для доступу до Jenkins"
  value       = "Виконай: kubectl get svc -n ${var.namespace} jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "admin_password_command" {
  description = "Команда для отримання пароля адміністратора"
  value       = "kubectl exec -n ${var.namespace} -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password"
}
