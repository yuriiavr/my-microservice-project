variable "aws_region" {
  description = "AWS-регіон для розгортання ресурсів."
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Глобально унікальне ім'я S3-бакета для Terraform-стейтів."
  type        = string
  default     = "yuriiavr-tf-state-lesson-8-9"
}

variable "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів."
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Назва ECR-репозиторію для Django-образу."
  type        = string
  default     = "lesson-8-9-django"
}

variable "cluster_name" {
  description = "Назва EKS-кластера."
  type        = string
  default     = "lesson-8-9-eks"
}

variable "cluster_version" {
  description = "Версія Kubernetes для EKS."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Типи інстансів для worker-нод."
  type        = list(string)
  default     = ["t3.large"]
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
  default     = 4
}

# --- Jenkins -----------------------------------------------------------------
variable "jenkins_namespace" {
  description = "Namespace для Jenkins."
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  description = "Версія Helm-чарта Jenkins (jenkins/jenkins)."
  type        = string
  default     = "5.7.15"
}

variable "jenkins_admin_user" {
  description = "Логін адміністратора Jenkins."
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins."
  type        = string
  default     = "admin123"
  sensitive   = true
}

# --- Argo CD -----------------------------------------------------------------
variable "argocd_namespace" {
  description = "Namespace для Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Версія Helm-чарта Argo CD (argo/argo-cd)."
  type        = string
  default     = "7.7.11"
}

# --- GitOps (за чим стежить Argo CD) -----------------------------------------
variable "git_repo_url" {
  description = "URL Git-репозиторію з Helm-чартом django-app."
  type        = string
  default     = "https://github.com/yuriiavr/my-microservice-project.git"
}

variable "git_target_revision" {
  description = "Гілка, у яку pipeline пушить оновлений тег і за якою стежить Argo CD."
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
