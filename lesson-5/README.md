# Lesson 5 — Terraform-інфраструктура на AWS

Terraform-проєкт, що створює базову інфраструктуру в AWS:

- **віддалений стейт** у S3 з блокуванням через DynamoDB;
- **мережу (VPC)** з публічними та приватними підмережами;
- **ECR** для зберігання Docker-образів.

## Структура проєкту

```
lesson-5/
├── main.tf                  # Підключення модулів + provider
├── backend.tf               # Бекенд S3 + DynamoDB для стейтів
├── variables.tf             # Кореневі змінні (регіон, ім'я бакета, таблиця)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/
│   ├── s3-backend/          # S3-бакет + DynamoDB для стейтів
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                 # VPC, підмережі, IGW, NAT, маршрути
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ecr/                 # ECR-репозиторій + політики
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

## Опис модулів

### s3-backend
Створює інфраструктуру для зберігання стейтів Terraform:
- `aws_s3_bucket` — бакет для `terraform.tfstate`;
- `aws_s3_bucket_versioning` — версіювання (історія стейтів);
- `aws_s3_bucket_server_side_encryption_configuration` — шифрування (AES256);
- `aws_s3_bucket_public_access_block` — блокування публічного доступу;
- `aws_dynamodb_table` (ключ `LockID`) — блокування стейтів від паралельних змін.

Виводить: ім'я та URL S3-бакета, ім'я таблиці DynamoDB.

### vpc
Створює мережу:
- `aws_vpc` із заданим CIDR-блоком (`10.0.0.0/16`);
- 3 публічні та 3 приватні підмережі в різних зонах доступності;
- `aws_internet_gateway` — вихід в Інтернет для публічних підмереж;
- `aws_nat_gateway` + `aws_eip` — вихідний трафік для приватних підмереж;
- `aws_route_table` + асоціації — маршрутизація для обох типів підмереж.

Виводить: `vpc_id`, ID публічних/приватних підмереж, ID IGW та NAT.

### ecr
Створює реєстр Docker-образів:
- `aws_ecr_repository` з `scan_on_push = true` (сканування вразливостей);
- `aws_ecr_repository_policy` — політика доступу (pull/push для акаунта);
- `aws_ecr_lifecycle_policy` — зберігання лише N останніх образів.

Виводить: URL, ARN та назву репозиторію.

## Передумови

- Встановлений [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.3);
- Налаштовані облікові дані AWS (`aws configure` або змінні `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`);
- Унікальне ім'я S3-бакета у `variables.tf` (`state_bucket_name`) та `backend.tf`.

> ⚠️ Ім'я S3-бакета має бути **глобально унікальним**. Змініть `state_bucket_name`
> у `variables.tf` і відповідне значення `bucket` у `backend.tf` на власне.

## Команди

```bash
# Ініціалізація (завантаження провайдерів та модулів)
terraform init

# Перегляд плану змін
terraform plan

# Застосування — створення ресурсів в AWS
terraform apply

# Видалення всіх створених ресурсів
terraform destroy
```

## Bootstrap бекенду (важливо)

Бекенд S3 потребує, щоб бакет і таблиця DynamoDB **вже існували** до `terraform init`
з блоком `backend "s3"`. Тому першого разу:

1. Тимчасово закоментуйте вміст `backend.tf` (буде використано локальний стейт).
2. Виконайте:
   ```bash
   terraform init
   terraform apply   # створить S3-бакет та DynamoDB
   ```
3. Розкоментуйте `backend.tf` і перенесіть стейт у S3:
   ```bash
   terraform init -migrate-state
   ```
