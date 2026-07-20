output "cluster_name" {
  description = "Назва EKS-кластера."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint API-сервера кластера."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  description = "ARN кластера."
  value       = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority" {
  description = "Certificate authority (base64) для підключення kubectl."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "Версія Kubernetes кластера."
  value       = aws_eks_cluster.this.version
}

output "node_group_name" {
  description = "Назва групи нод."
  value       = aws_eks_node_group.this.node_group_name
}

output "oidc_provider_arn" {
  description = "ARN OIDC-провайдера (для IRSA-ролей)."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "URL OIDC-провайдера без схеми https:// (для умов у trust policy)."
  value       = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}
