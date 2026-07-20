variable "aws_region" {
  description = "AWS-регіон для розгортання ресурсів."
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Глобально унікальне ім'я S3-бакета для Terraform-стейтів."
  type        = string
  default     = "yuriiavr-tf-state-lesson-7"
}

variable "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів."
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Назва ECR-репозиторію для Django-образу."
  type        = string
  default     = "lesson-7-django"
}

variable "cluster_name" {
  description = "Назва EKS-кластера."
  type        = string
  default     = "lesson-7-eks"
}

variable "cluster_version" {
  description = "Версія Kubernetes для EKS."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Типи інстансів для worker-нод."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Бажана кількість нод."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість нод."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Максимальна кількість нод."
  type        = number
  default     = 3
}
