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
