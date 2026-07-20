variable "namespace" {
  description = "Namespace для Jenkins."
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Версія Helm-чарта jenkins/jenkins."
  type        = string
  default     = "5.7.15"
}

variable "admin_user" {
  description = "Логін адміністратора Jenkins."
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Пароль адміністратора Jenkins."
  type        = string
  sensitive   = true
}

variable "agent_service_account" {
  description = "ServiceAccount, під яким піднімаються агенти (kaniko) і який має IRSA-роль з доступом до ECR."
  type        = string
  default     = "jenkins-agent"
}

variable "cluster_name" {
  description = "Назва EKS-кластера (для іменування IAM-ролей)."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC-провайдера кластера."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC-провайдера без https://."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN ECR-репозиторію, у який kaniko пушить образ."
  type        = string
}
