output "namespace" {
  description = "Namespace, у якому встановлено Argo CD."
  value       = var.namespace
}

output "url_command" {
  description = "Команда для отримання зовнішньої адреси Argo CD."
  value       = "kubectl -n ${var.namespace} get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "admin_password_command" {
  description = "Команда для отримання початкового пароля admin у Argo CD."
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
