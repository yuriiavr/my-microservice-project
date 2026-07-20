output "namespace" {
  description = "Namespace, у якому встановлено Jenkins."
  value       = var.namespace
}

output "agent_role_arn" {
  description = "ARN IRSA-ролі агента Jenkins (доступ до ECR)."
  value       = aws_iam_role.agent.arn
}

output "url_command" {
  description = "Команда для отримання зовнішньої адреси Jenkins."
  value       = "kubectl -n ${var.namespace} get svc jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "admin_password_command" {
  description = "Команда для отримання пароля адміністратора Jenkins."
  value       = "kubectl -n ${var.namespace} get secret jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d"
}
