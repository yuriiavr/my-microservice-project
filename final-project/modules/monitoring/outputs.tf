output "namespace" {
  description = "Namespace стеку моніторингу."
  value       = var.namespace
}

output "grafana_port_forward_command" {
  description = "Команда для доступу до Grafana (http://localhost:3000)."
  value       = "kubectl -n ${var.namespace} port-forward svc/grafana 3000:80"
}

output "grafana_admin_password_command" {
  description = "Команда для отримання пароля адміністратора Grafana."
  value       = "kubectl -n ${var.namespace} get secret grafana -o jsonpath='{.data.admin-password}' | base64 -d"
}

output "prometheus_port_forward_command" {
  description = "Команда для доступу до Prometheus (http://localhost:9090)."
  value       = "kubectl -n ${var.namespace} port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090"
}
