variable "vpc_cidr_block" {
  description = "CIDR-блок для VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Список CIDR-блоків публічних підмереж."
  type        = list(string)
}

variable "private_subnets" {
  description = "Список CIDR-блоків приватних підмереж."
  type        = list(string)
}

variable "availability_zones" {
  description = "Список зон доступності для підмереж."
  type        = list(string)
}

variable "vpc_name" {
  description = "Назва VPC (використовується в тегах)."
  type        = string
  default     = "lesson-5-vpc"
}
