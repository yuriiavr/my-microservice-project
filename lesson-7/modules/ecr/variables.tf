variable "ecr_name" {
  description = "Назва ECR-репозиторію."
  type        = string
}

variable "scan_on_push" {
  description = "Автоматичне сканування образів при push."
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Мутабельність тегів образів (MUTABLE або IMMUTABLE)."
  type        = string
  default     = "MUTABLE"
}

variable "max_image_count" {
  description = "Скільки останніх образів зберігати (lifecycle policy)."
  type        = number
  default     = 10
}
