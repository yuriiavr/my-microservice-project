variable "namespace" {
  description = "Namespace для Argo CD."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Helm-чарта argo/argo-cd."
  type        = string
  default     = "7.7.11"
}

variable "git_repo_url" {
  description = "URL Git-репозиторію з Helm-чартом django-app."
  type        = string
}

variable "git_target_revision" {
  description = "Гілка/тег, за якою стежить Argo CD."
  type        = string
  default     = "main"
}

variable "app_chart_path" {
  description = "Шлях до Helm-чарта django-app усередині репозиторію."
  type        = string
  default     = "lesson-8-9/charts/django-app"
}

variable "app_namespace" {
  description = "Namespace, у який Argo CD розгортає django-app."
  type        = string
  default     = "django"
}

variable "app_name" {
  description = "Ім'я Argo CD Application."
  type        = string
  default     = "django-app"
}
