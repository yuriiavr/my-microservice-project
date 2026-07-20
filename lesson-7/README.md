# Lesson 7 — Kubernetes (EKS) + ECR + Helm

Кластер Kubernetes (Amazon EKS) у тій самій VPC, що й у попередніх темах, репозиторій
ECR для Django-образу та Helm-чарт для розгортання застосунку.

## Структура

```
lesson-7/
├── main.tf              # підключення модулів (s3-backend, vpc, ecr, eks)
├── backend.tf           # бекенд стейтів (S3 + DynamoDB)
├── variables.tf         # змінні кореневого модуля
├── outputs.tf           # загальні виводи
├── modules/
│   ├── s3-backend/      # S3-бакет + DynamoDB для стейтів
│   ├── vpc/             # VPC, підмережі, IGW, NAT, теги для ELB/EKS
│   ├── ecr/             # ECR-репозиторій
│   └── eks/             # EKS-кластер + node group + IAM-ролі
└── charts/
    └── django-app/      # Helm-чарт (deployment, service, hpa, configmap)
```

## 1. Розгортання інфраструктури (Terraform)

Bootstrap бекенду (перший запуск): у `backend.tf` тимчасово закоментуйте блок `backend "s3"`,
щоб Terraform використав локальний стейт і створив бакет із таблицею.

```bash
cd lesson-7
terraform init
terraform apply -target=module.s3_backend    # створити S3 + DynamoDB
```

Далі розкоментуйте блок `backend "s3"` та перенесіть стейт у S3:

```bash
terraform init -migrate-state
terraform apply                                # VPC + ECR + EKS
```

> Створення EKS-кластера та node group займає ~10–15 хвилин.

## 2. Доступ до кластера (kubectl)

```bash
$(terraform output -raw kubeconfig_command)
# або вручну:
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks

kubectl get nodes           # мають бути 2 ноди у стані Ready
```

## 3. Завантаження Django-образу до ECR

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=us-west-2

# Логін у ECR
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin ${ECR_URL%/*}

# Збірка образу (Dockerfile — у корені репозиторію, тема 4)
docker build -t django-app ..

# Тегування та push
docker tag django-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

## 4. Розгортання застосунку (Helm)

У `charts/django-app/values.yaml` вкажіть `image.repository` = значення `ecr_repository_url`
(без тегу), напр. `123456789012.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django`.

```bash
helm install django-app ./charts/django-app \
  --set image.repository=$ECR_URL

# перевірка
kubectl get pods
kubectl get svc django-app        # EXTERNAL-IP — DNS-ім'я LoadBalancer
kubectl get hpa django-app        # масштабування 2..6 при CPU > 70%
```

Застосунок буде доступний за адресою `http://<EXTERNAL-IP>` (DNS-ім'я AWS ELB).

Оновлення після нового push образу:

```bash
helm upgrade django-app ./charts/django-app --set image.repository=$ECR_URL
kubectl rollout restart deployment/django-app
```

## Helm-чарт

- **deployment.yaml** — Django-образ з ECR, змінні середовища через `envFrom` → ConfigMap;
  задані `resources.requests.cpu` (потрібні для роботи HPA).
- **service.yaml** — тип `LoadBalancer`, порт 80 → 8000.
- **hpa.yaml** — HorizontalPodAutoscaler: `minReplicas: 2`, `maxReplicas: 6`, CPU 70%.
- **configmap.yaml** — env-змінні, перенесені з `.env` теми 4 (Postgres + Django).
- **values.yaml** — параметри образу, сервісу, ресурсів, автоскейлера та конфігурації.

> HPA потребує metrics-server у кластері:
> `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

## Прибирання

```bash
helm uninstall django-app
terraform destroy
```
