# =============================================================================
# Загальні / перемикач типу БД
# =============================================================================
variable "identifier" {
  description = "Базове ім'я для всіх ресурсів БД (інстанс/кластер, subnet group, SG, parameter group)."
  type        = string
}

variable "use_aurora" {
  description = "true → Aurora Cluster + інстанси; false → одна звичайна RDS instance."
  type        = bool
  default     = false
}

# =============================================================================
# Параметри рушія БД
# =============================================================================
variable "engine" {
  description = "Рушій БД. RDS: postgres | mysql. Aurora: aurora-postgresql | aurora-mysql."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія рушія (напр. 15.4 для postgres, 8.0 для mysql)."
  type        = string
  default     = "15.8"
}

variable "instance_class" {
  description = "Клас інстансу (напр. db.t3.medium для RDS, db.r6g.large для Aurora)."
  type        = string
  default     = "db.t3.medium"
}

variable "parameter_group_family" {
  description = "Родина parameter group. Має відповідати engine+version: postgres15 | mysql8.0 | aurora-postgresql15 | aurora-mysql8.0."
  type        = string
  default     = "postgres15"
}

variable "port" {
  description = "Порт БД. null → 5432 для postgres, 3306 для mysql."
  type        = number
  default     = null
}

# =============================================================================
# Тільки для звичайної RDS instance (use_aurora = false)
# =============================================================================
variable "multi_az" {
  description = "Multi-AZ для звичайної RDS instance (резервна репліка в іншій AZ)."
  type        = bool
  default     = false
}

variable "allocated_storage" {
  description = "Розмір диску (ГБ) для звичайної RDS instance."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Тип диску для RDS instance (gp3, gp2, io1)."
  type        = string
  default     = "gp3"
}

# =============================================================================
# Тільки для Aurora (use_aurora = true)
# =============================================================================
variable "aurora_instance_count" {
  description = "Кількість інстансів у кластері Aurora (1 writer + решта readers)."
  type        = number
  default     = 2
}

# =============================================================================
# Облікові дані та ім'я БД
# =============================================================================
variable "db_name" {
  description = "Ім'я початкової бази даних."
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Логін master-користувача БД."
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Пароль master-користувача. ОБОВ'ЯЗКОВО перевизначте у продакшені (краще через Secrets Manager)."
  type        = string
  default     = "ChangeMeSecure123"
  sensitive   = true
}

# =============================================================================
# Мережа
# =============================================================================
variable "subnet_ids" {
  description = "Список ID підмереж для DB Subnet Group (зазвичай приватні, у 2+ AZ)."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID VPC, у якій створюється Security Group."
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR-блоки, яким дозволено доступ до порту БД."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "ID Security Group, яким дозволено доступ до порту БД (напр. SG нод EKS)."
  type        = list(string)
  default     = []
}

# =============================================================================
# Parameter group — базові параметри
# =============================================================================
variable "parameters" {
  description = "Параметри для parameter group (за замовчуванням — базові для PostgreSQL)."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = [
    { name = "max_connections", value = "100" },
    { name = "log_statement", value = "all" },
    { name = "work_mem", value = "4096" },
  ]
}

# =============================================================================
# Життєвий цикл
# =============================================================================
variable "skip_final_snapshot" {
  description = "Пропускати фінальний снапшот при видаленні (true для навчального стенду)."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Захист від випадкового видалення БД."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Публічний доступ до RDS instance (для навчання зазвичай false)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Додаткові теги для ресурсів БД."
  type        = map(string)
  default     = {}
}
