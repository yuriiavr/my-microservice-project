# Модуль `rds` — універсальна БД (RDS instance або Aurora Cluster)

Один модуль піднімає **звичайну RDS instance** (PostgreSQL/MySQL) або **Aurora Cluster**
залежно від прапора `use_aurora`. В обох випадках створюються DB Subnet Group,
Security Group і Parameter Group.

## Що створюється

| Ресурс | `use_aurora = false` | `use_aurora = true` |
|--------|:--------------------:|:-------------------:|
| DB Subnet Group | ✅ | ✅ |
| Security Group | ✅ | ✅ |
| Parameter Group | `aws_db_parameter_group` | `aws_rds_cluster_parameter_group` |
| БД | `aws_db_instance` | `aws_rds_cluster` + `aws_rds_cluster_instance` (writer + readers) |

## Приклад: звичайна RDS PostgreSQL

```hcl
module "rds" {
  source = "./modules/rds"

  identifier = "myapp-db"
  use_aurora = false

  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.medium"
  parameter_group_family = "postgres15"
  multi_az               = true

  db_name         = "appdb"
  master_username = "dbadmin"
  master_password = var.db_password   # передавайте через TF_VAR / Secrets Manager

  subnet_ids          = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
}
```

## Приклад: Aurora PostgreSQL

Змінюється лише кілька значень:

```hcl
module "rds" {
  source = "./modules/rds"

  identifier = "myapp-db"
  use_aurora = true                    # ← перемикач

  engine                 = "aurora-postgresql"
  engine_version         = "15.4"
  instance_class         = "db.r6g.large"
  parameter_group_family = "aurora-postgresql15"
  aurora_instance_count  = 2           # 1 writer + 1 reader

  db_name         = "appdb"
  master_username = "dbadmin"
  master_password = var.db_password

  subnet_ids          = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
}
```

## Як що змінити

- **Тип БД (RDS ↔ Aurora):** `use_aurora = true|false`. Для Aurora також задайте
  `engine = "aurora-postgresql"` (або `aurora-mysql`) і відповідний `parameter_group_family`.
- **Рушій:** `engine` (`postgres` / `mysql` / `aurora-postgresql` / `aurora-mysql`) +
  `engine_version` + `parameter_group_family` (мають узгоджуватись, напр.
  `mysql` + `8.0` + `mysql8.0`). Порт визначається автоматично (5432/3306) або через `port`.
- **Клас інстансу:** `instance_class` (напр. `db.t3.medium`, `db.r6g.large`).
- **Multi-AZ:** для RDS instance — `multi_az = true`; Aurora розподіляє інстанси по AZ сам
  (керується `aurora_instance_count`).
- **Параметри БД:** список `parameters` (за замовчуванням `max_connections`, `log_statement`,
  `work_mem` для PostgreSQL). Для MySQL/Aurora задайте валідні для рушія параметри.

## Змінні

| Змінна | Тип | Дефолт | Опис |
|--------|-----|--------|------|
| `identifier` | string | — | Базове ім'я всіх ресурсів БД |
| `use_aurora` | bool | `false` | true → Aurora Cluster; false → RDS instance |
| `engine` | string | `postgres` | Рушій БД |
| `engine_version` | string | `15.4` | Версія рушія |
| `instance_class` | string | `db.t3.medium` | Клас інстансу |
| `parameter_group_family` | string | `postgres15` | Родина parameter group (під engine+version) |
| `port` | number | `null` | Порт (null → 5432/3306 за рушієм) |
| `multi_az` | bool | `false` | Multi-AZ для RDS instance |
| `allocated_storage` | number | `20` | Розмір диску RDS instance (ГБ) |
| `storage_type` | string | `gp3` | Тип диску RDS instance |
| `aurora_instance_count` | number | `2` | Кількість інстансів Aurora (writer + readers) |
| `db_name` | string | `appdb` | Ім'я початкової БД |
| `master_username` | string | `dbadmin` | Логін master-користувача |
| `master_password` | string (sensitive) | `ChangeMeSecure123` | Пароль master (перевизначте!) |
| `subnet_ids` | list(string) | — | Підмережі для DB Subnet Group |
| `vpc_id` | string | — | VPC для Security Group |
| `allowed_cidr_blocks` | list(string) | `[]` | CIDR, яким дозволено доступ до порту |
| `allowed_security_group_ids` | list(string) | `[]` | SG, яким дозволено доступ до порту |
| `parameters` | list(object) | 3 базові Postgres-параметри | Параметри parameter group |
| `skip_final_snapshot` | bool | `true` | Пропускати фінальний снапшот |
| `deletion_protection` | bool | `false` | Захист від видалення |
| `publicly_accessible` | bool | `false` | Публічний доступ |
| `tags` | map(string) | `{}` | Додаткові теги |

## Виводи

| Вивід | Опис |
|-------|------|
| `endpoint` | Адреса підключення (RDS address або Aurora writer endpoint) |
| `reader_endpoint` | Reader endpoint (тільки Aurora) |
| `port` | Порт БД |
| `database_name` | Ім'я БД |
| `security_group_id` | ID Security Group |
| `db_subnet_group_name` | Ім'я DB Subnet Group |
| `parameter_group_name` | Ім'я parameter group |
| `is_aurora` | Чи це Aurora |
