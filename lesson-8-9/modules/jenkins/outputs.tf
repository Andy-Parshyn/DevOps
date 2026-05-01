output "jenkins_url_command" {
  description = "Команда для отримання URL/hostname Jenkins"
  value       = "kubectl get svc -n ${var.namespace} jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "admin_password_command" {
  description = "Команда для отримання пароля адміністратора"
  value       = "kubectl exec -n ${var.namespace} -it statefulset/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password"
}
