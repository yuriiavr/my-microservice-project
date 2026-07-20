variable "aws_region" {
  description = "AWS-регіон для розгортання ресурсів."
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Глобально унікальне ім'я S3-бакета для Terraform-стейтів."
  type        = string
  default     = "yuriiavr-tf-state-lesson-db-module"
}

variable "dynamodb_table_name" {
  description = "Ім'я таблиці DynamoDB для блокування стейтів."
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Назва ECR-репозиторію для Django-образу."
  type        = string
  default     = "lesson-db-module-django"
}

variable "cluster_name" {
  description = "Назва EKS-кластера."
  type        = string
  default     = "lesson-db-module-eks"
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
  default     = "lesson-db-module/charts/django-app"
}

variable "app_namespace" {
  description = "Namespace, у який Argo CD розгортає django-app."
  type        = string
  default     = "django"
}

# --- БД (модуль rds) ---------------------------------------------------------
variable "db_identifier" {
  description = "Базове ім'я ресурсів БД."
  type        = string
  default     = "lesson-db"
}

variable "db_use_aurora" {
  description = "true → Aurora Cluster; false → звичайна RDS instance."
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "Рушій БД (postgres | mysql | aurora-postgresql | aurora-mysql)."
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Версія рушія БД."
  type        = string
  default     = "15.8"
}

variable "db_instance_class" {
  description = "Клас інстансу БД."
  type        = string
  default     = "db.t3.medium"
}

variable "db_parameter_group_family" {
  description = "Родина parameter group (postgres15 | mysql8.0 | aurora-postgresql15 | ...)."
  type        = string
  default     = "postgres15"
}

variable "db_multi_az" {
  description = "Multi-AZ для звичайної RDS instance."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Ім'я початкової бази даних."
  type        = string
  default     = "appdb"
}

variable "db_master_username" {
  description = "Логін master-користувача БД."
  type        = string
  default     = "dbadmin"
}

variable "db_master_password" {
  description = "Пароль master-користувача БД (перевизначте через TF_VAR_db_master_password)."
  type        = string
  default     = "ChangeMeSecure123"
  sensitive   = true
}
