# Фінальний проєкт — DevOps-платформа в AWS

Повна інфраструктура під Django-застосунок в AWS, розгорнута одним `terraform apply`:
**VPC + EKS + RDS + ECR + Jenkins + Argo CD + Prometheus + Grafana**.
CI/CD (Jenkins → ECR → Git → Argo CD) і моніторинг (Prometheus/Grafana) з автомасштабуванням (HPA).

## Архітектура

```
                          ┌──────────────────────── AWS VPC (10.0.0.0/16) ─────────────────────────┐
                          │                                                                          │
  Developer ── git push ─┼─▶ Jenkins (ns: jenkins) ── Kaniko build ──▶ ECR                          │
      │                   │        │ bump tag у values.yaml, push у main                             │
      │                   │        ▼                                                                  │
      │                   │   GitHub repo ◀── watch ── Argo CD (ns: argocd) ── sync ──▶ django-app   │
      │                   │                                                        (ns: django, HPA)  │
      │                   │                                                             │             │
      │                   │   RDS / Aurora (private subnets) ◀───────────────────────── │             │
      │                   │                                                             ▼             │
      │                   │   Prometheus + Grafana (ns: monitoring) ◀── метрики ── EKS nodes / pods   │
      │                   │                                                                          │
      │                   │   public subnets:  IGW, NAT, LoadBalancer-и                              │
      │                   │   private subnets: EKS nodes, RDS                                         │
                          └──────────────────────────────────────────────────────────────────────────┘
```

## Компоненти (модулі Terraform)

| Модуль | Призначення |
|--------|-------------|
| `s3-backend` | S3-бакет + DynamoDB для стейтів Terraform |
| `vpc` | VPC, публічні/приватні підмережі, IGW, NAT, теги для ELB/EKS |
| `ecr` | Реєстр Docker-образів |
| `eks` | Kubernetes-кластер + OIDC (IRSA) + EBS CSI driver + gp3 StorageClass |
| `rds` | Універсальна БД: звичайна RDS або Aurora (`use_aurora`) |
| `jenkins` | Helm-реліз Jenkins + IRSA-роль агента Kaniko (push у ECR) |
| `argo_cd` | Helm-реліз Argo CD + Application (GitOps auto-sync) |
| `monitoring` | Helm-реліз kube-prometheus-stack (Prometheus + Grafana + alertmanager) |

## 1. Підготовка та розгортання

```bash
cd final-project

export TF_VAR_db_master_password='password'
export TF_VAR_grafana_admin_password='grafana'

terraform init
terraform apply
```

> **Bootstrap бекенду (перший запуск):** S3-бакет і DynamoDB мають існувати ДО `init` з
> бекендом S3. Тому першого разу закоментуйте блок `backend "s3"` у `backend.tf`, виконайте
> `terraform init` та `terraform apply -target=module.s3_backend`, потім розкоментуйте блок і
> `terraform init -migrate-state`.

> **Порядок першого apply:** helm/kubernetes-провайдери автентифікуються в EKS, тому кластер
> має існувати ДО встановлення Helm-релізів. Якщо перший `terraform apply` впаде на автентифікації
> провайдера — спершу підніміть кластер, потім усе решта:
> ```bash
> terraform apply -target=module.vpc -target=module.eks
> terraform apply
> ```

> **Версія БД:** мінорні версії RDS з часом застарівають. Перед apply перевірте доступні в регіоні:
> ```bash
> aws rds describe-db-engine-versions --engine postgres \
>   --query 'DBEngineVersions[].EngineVersion' --output text
> ```
> і за потреби задайте `-var db_engine_version=<версія>` (та відповідний `db_parameter_group_family`).

> **ECR у values.yaml:** `image.repository` містить заглушку account id `123456789012` —
> підставте свій (`terraform output -raw ecr_repository_url`), він має збігатися з `ECR_REGISTRY`
> у Jenkinsfile.

Доступ до кластера:

```bash
aws eks update-kubeconfig --region us-west-2 --name final-project-eks
```

## 2. Перевірка стану ресурсів

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get all -n django
```

## 3. Доступ до сервісів

```bash
# Jenkins  → http://localhost:8080
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl -n jenkins get secret jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d

# Argo CD  → https://localhost:8081
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Grafana  → http://localhost:3000  (admin / TF_VAR_grafana_admin_password)
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## 4. CI/CD

Пайплайн — у [Django/Jenkinsfile](Django/Jenkinsfile):

1. Kaniko збирає образ із `Django/Dockerfile` і пушить у **ECR**;
2. `sed` оновлює `image.tag` у `charts/django-app/values.yaml` і пушить у `main`;
3. **Argo CD** бачить комміт і автоматично синхронізує застосунок у кластері (`prune` + `selfHeal`).

Налаштування Jenkins job: створити credential `github-token` (GitHub PAT), додати Pipeline
*from SCM* зі *Script Path* = `final-project/Django/Jenkinsfile`. Push у ECR іде через IRSA-роль
агента (окремі AWS-ключі не потрібні).

## 5. Моніторинг та автомасштабування

- **Метрики:** Prometheus збирає метрики нод/подів (node-exporter, kube-state-metrics),
  Grafana показує їх на готових дашбордах Kubernetes.
- **Автомасштабування подів:** HPA у [charts/django-app/templates/hpa.yaml](charts/django-app/templates/hpa.yaml) —
  від 2 до 6 реплік при CPU > 70% (metrics-server / metrics API).
- **Автомасштабування нод:** EKS managed node group `min=2 … max=4`.

## Безпека

- **Мережа:** ноди EKS і RDS — у **приватних** підмережах; вихід в інтернет через NAT;
  назовні дивляться лише LoadBalancer-и в публічних підмережах.
- **IAM / IRSA:** кожен сервіс отримує мінімальні права через OIDC — EBS CSI, а агент Jenkins
  має лише `ecr:*` на конкретний репозиторій.
- **Security Groups:** модуль `rds` відкриває порт БД лише для CIDR VPC / вказаних SG;
  публічний доступ до БД вимкнено.
- **Стейт:** S3 з шифруванням і версіюванням + блокування через DynamoDB.

## Структура

```
final-project/
├── main.tf  backend.tf  variables.tf  outputs.tf
├── modules/  (s3-backend, vpc, ecr, eks, rds, jenkins, argo_cd, monitoring)
├── charts/django-app/          # Helm-чарт застосунку (deployment/service/hpa/configmap)
└── Django/
    ├── app/                    # код Django (manage.py, myproject/, nginx/)
    ├── Dockerfile
    ├── Jenkinsfile
    └── docker-compose.yaml
```

## Видалення ресурсів ⚠️

Хмарні ресурси платні — після перевірки видаліть усе:

```bash
terraform destroy
```

> **Порядок після destroy:** `terraform destroy` видаляє і S3-бакет із DynamoDB-таблицею
> (бекенд стейтів). Щоб підняти інфраструктуру знову, спершу заново зробіть bootstrap бекенду
> (див. крок 1), і лише потім `terraform apply`.
