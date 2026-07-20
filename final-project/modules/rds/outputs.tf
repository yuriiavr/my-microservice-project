output "endpoint" {
  description = "Адреса для підключення (RDS instance address або Aurora writer endpoint)."
  value       = var.use_aurora ? one(aws_rds_cluster.this[*].endpoint) : one(aws_db_instance.this[*].address)
}

output "reader_endpoint" {
  description = "Reader endpoint (тільки для Aurora; для RDS instance — null)."
  value       = var.use_aurora ? one(aws_rds_cluster.this[*].reader_endpoint) : null
}

output "port" {
  description = "Порт БД."
  value       = local.port
}

output "database_name" {
  description = "Ім'я створеної бази даних."
  value       = var.db_name
}

output "security_group_id" {
  description = "ID Security Group бази даних."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Ім'я DB Subnet Group."
  value       = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Ім'я створеного parameter group."
  value       = var.use_aurora ? one(aws_rds_cluster_parameter_group.this[*].name) : one(aws_db_parameter_group.this[*].name)
}

output "is_aurora" {
  description = "Чи створено Aurora Cluster (true) або звичайну RDS instance (false)."
  value       = var.use_aurora
}
