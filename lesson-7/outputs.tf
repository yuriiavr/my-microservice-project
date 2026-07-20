# --- Загальні вихідні дані з усіх модулів ------------------------------------

# S3-backend
output "s3_bucket_name" {
  description = "Ім'я S3-бакета зі стейтами."
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокувань."
  value       = module.s3_backend.dynamodb_table_name
}

# VPC
output "vpc_id" {
  description = "ID створеної VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "ID публічних підмереж."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID приватних підмереж."
  value       = module.vpc.private_subnet_ids
}

# ECR
output "ecr_repository_url" {
  description = "URL ECR-репозиторію (для docker push та поля image.repository у values.yaml)."
  value       = module.ecr.repository_url
}

# EKS
output "eks_cluster_name" {
  description = "Назва EKS-кластера."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint API-сервера кластера."
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Команда для налаштування доступу kubectl до кластера."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
