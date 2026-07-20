# --- Загальні вихідні дані з усіх модулів ------------------------------------

# VPC
output "vpc_id" {
  description = "ID створеної VPC."
  value       = module.vpc.vpc_id
}

# ECR
output "ecr_repository_url" {
  description = "URL ECR-репозиторію (для docker/kaniko push та поля image.repository у values.yaml)."
  value       = module.ecr.repository_url
}

# EKS
output "eks_cluster_name" {
  description = "Назва EKS-кластера."
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Команда для налаштування доступу kubectl до кластера."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Jenkins
output "jenkins_url_command" {
  description = "Команда, щоб дізнатись зовнішню адресу Jenkins."
  value       = "kubectl -n ${var.jenkins_namespace} get svc jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "jenkins_admin_password_command" {
  description = "Команда для отримання пароля адміністратора Jenkins."
  value       = "kubectl -n ${var.jenkins_namespace} get secret jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d"
}

# Argo CD
output "argocd_url_command" {
  description = "Команда, щоб дізнатись зовнішню адресу Argo CD."
  value       = "kubectl -n ${var.argocd_namespace} get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_admin_password_command" {
  description = "Команда для отримання початкового пароля admin у Argo CD."
  value       = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
