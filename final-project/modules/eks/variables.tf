variable "cluster_name" {
  description = "Назва EKS-кластера."
  type        = string
}

variable "cluster_version" {
  description = "Версія Kubernetes для control plane."
  type        = string
  default     = "1.30"
}

variable "subnet_ids" {
  description = "Список підмереж для control plane (публічні + приватні)."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Список підмереж для worker-нод (зазвичай приватні)."
  type        = list(string)
}

variable "node_instance_types" {
  description = "Типи інстансів для worker-нод."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Бажана кількість нод у групі."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість нод у групі."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Максимальна кількість нод у групі."
  type        = number
  default     = 3
}
