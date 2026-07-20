variable "bucket_name" {
  description = "Глобально унікальне ім'я S3-бакета для стейт-файлів Terraform."
  type        = string
}

variable "table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів."
  type        = string
  default     = "terraform-locks"
}

variable "tags" {
  description = "Додаткові теги для ресурсів."
  type        = map(string)
  default     = {}
}
