output "s3_bucket_name" {
  description = "Ім'я S3-бакета зі стейтами."
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN S3-бакета."
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_url" {
  description = "URL (regional domain name) S3-бакета."
  value       = aws_s3_bucket.terraform_state.bucket_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокувань."
  value       = aws_dynamodb_table.terraform_locks.name
}
