# --- Загальні вихідні дані з усіх модулів ------------------------------------

# S3-backend
output "s3_bucket_name" {
  description = "Ім'я S3-бакета зі стейтами."
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_url" {
  description = "URL (domain name) S3-бакета."
  value       = module.s3_backend.s3_bucket_url
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
  description = "URL ECR-репозиторію."
  value       = module.ecr.repository_url
}
