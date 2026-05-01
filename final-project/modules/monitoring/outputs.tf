output "grafana_url_command" {
  value = "kubectl -n ${var.namespace} port-forward svc/kube-prometheus-stack-grafana 3000:80"
}

output "prometheus_url_command" {
  value = "kubectl -n ${var.namespace} port-forward svc/kube-prometheus-stack-prometheus 9090:9090"
}

output "grafana_admin_password_command" {
  value = "kubectl -n ${var.namespace} get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
}
