variable "aws_region" {
  description = "AWS-регіон для розгортання ресурсів."
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Глобально унікальне ім'я S3-бакета для Terraform-стейтів. ОБОВ'ЯЗКОВО змініть на власне унікальне."
  type        = string
  default     = "yuriiavr-tf-state-lesson-5"
}

variable "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів."
  type        = string
  default     = "terraform-locks"
}
