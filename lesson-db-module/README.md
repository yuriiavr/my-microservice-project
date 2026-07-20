# Lesson DB Module — універсальний Terraform-модуль для баз даних

Гнучкий, багаторазовий модуль [`modules/rds`](modules/rds), який одним прапором
`use_aurora` піднімає **звичайну RDS instance** (PostgreSQL/MySQL) або **Aurora Cluster**.
Модуль додано до кумулятивного проєкту з попередніх тем (s3-backend, vpc, ecr, eks,
jenkins, argo_cd).

## Модуль `rds` — головне

| | `use_aurora = false` | `use_aurora = true` |
|--|:--:|:--:|
| БД | `aws_db_instance` | `aws_rds_cluster` + інстанси (writer + readers) |
| Parameter Group | `aws_db_parameter_group` | `aws_rds_cluster_parameter_group` |
| DB Subnet Group | ✅ | ✅ |
| Security Group | ✅ | ✅ |

Повний опис усіх змінних, виводів і прикладів — у [modules/rds/README.md](modules/rds/README.md).

### Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  identifier = "lesson-db"
  use_aurora = false                   # true → Aurora Cluster

  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.medium"
  parameter_group_family = "postgres15"
  multi_az               = true

  db_name         = "appdb"
  master_username = "dbadmin"
  master_password = var.db_master_password

  subnet_ids          = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
}
```

Перемкнути на Aurora — три зміни:

```hcl
  use_aurora             = true
  engine                 = "aurora-postgresql"
  parameter_group_family = "aurora-postgresql15"
```

## Як застосувати (Terraform)

Bootstrap бекенду (перший запуск): у `backend.tf` тимчасово закоментуйте блок `backend "s3"`.

```bash
cd lesson-db-module
terraform init
terraform apply -target=module.s3_backend      # S3 + DynamoDB
# розкоментуйте backend "s3"
terraform init -migrate-state

# лише мережа + БД (швидко й дешево — без EKS/Jenkins/Argo):
terraform apply -target=module.vpc -target=module.rds

# або весь кумулятивний стек:
terraform apply
```

Пароль БД передавайте змінною середовища, а не у файлі:

```bash
export TF_VAR_db_master_password='МійНадійнийПароль123'
```

Перевірити результат:

```bash
terraform output db_endpoint
terraform output db_port
```

## Структура

```
lesson-db-module/
├── main.tf                 # підключення модулів (+ module "rds")
├── backend.tf              # S3 + DynamoDB
├── variables.tf            # у т.ч. db_* змінні
├── outputs.tf              # у т.ч. db_endpoint / db_port
└── modules/
    ├── rds/                # ★ універсальний модуль БД
    │   ├── shared.tf       # DB Subnet Group + Security Group + locals
    │   ├── rds.tf          # aws_db_instance + parameter group (use_aurora=false)
    │   ├── aurora.tf       # aws_rds_cluster + інстанси + cluster parameter group (use_aurora=true)
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── s3-backend/  vpc/  ecr/  eks/  jenkins/  argo_cd/   # з попередніх тем
```

## Вартість

RDS/Aurora, EKS та LoadBalancer-и — платні. Після перевірки:

```bash
terraform destroy
```
