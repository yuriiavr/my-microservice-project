# Lesson 8-9 — CI/CD: Jenkins + Helm + Terraform + Argo CD

Повний GitOps-конвеєр для Django-застосунку в Amazon EKS:

1. **Jenkins** (агент Kaniko) збирає Docker-образ і пушить його в **ECR**;
2. pipeline оновлює тег образу у `values.yaml` та пушить зміну в Git;
3. **Argo CD** бачить зміну в Git і автоматично синхронізує застосунок у кластері.

Уся інфраструктура (VPC, EKS, ECR, Jenkins, Argo CD) піднімається через **Terraform**.

## Схема CI/CD

```
   git push (код)                              docker image
  ┌──────────────┐   webhook / вручну   ┌─────────────────────┐   push    ┌───────────┐
  │  Developer   │ ───────────────────▶ │  Jenkins (K8s agent │ ────────▶ │    ECR    │
  │   (GitHub)   │                      │   Kaniko + Git)     │           │  (образи) │
  └──────────────┘                      └─────────┬───────────┘           └───────────┘
         ▲                                         │ 2) sed: bump image.tag
         │                                         │    git commit + push (main)
         │ 4) sync manifests                       ▼
  ┌──────┴───────┐   watch main    ┌───────────────────────────┐
  │   Argo CD    │ ◀────────────── │  values.yaml (Helm chart) │
  │ (auto-sync)  │                 └───────────────────────────┘
  └──────┬───────┘
         │ 3) kubectl apply (deployment/service/hpa/configmap)
         ▼
  ┌──────────────┐
  │  EKS cluster │  ← django-app (новий образ)
  └──────────────┘
```

## Структура

```
lesson-8-9/
├── main.tf                 # провайдери (aws/kubernetes/helm) + підключення модулів
├── backend.tf              # S3 + DynamoDB для стейтів
├── variables.tf
├── outputs.tf
├── Jenkinsfile             # pipeline: Kaniko build → ECR → bump values.yaml → git push
├── modules/
│   ├── s3-backend/         # S3 + DynamoDB
│   ├── vpc/                # VPC, підмережі, IGW, NAT
│   ├── ecr/                # ECR-репозиторій
│   ├── eks/                # кластер + OIDC + EBS CSI driver (aws_ebs_csi_driver.tf)
│   ├── jenkins/            # Helm-реліз Jenkins + IRSA-роль агента (push у ECR)
│   └── argo_cd/            # Helm-реліз Argo CD + app-of-apps chart (Application + Repository)
│       └── charts/
└── charts/
    └── django-app/         # Helm-чарт застосунку (deployment/service/hpa/configmap)
```

## 1. Розгортання інфраструктури (Terraform)

Bootstrap бекенду (перший запуск): у `backend.tf` тимчасово закоментуйте блок `backend "s3"`.

```bash
cd lesson-8-9
terraform init
terraform apply -target=module.s3_backend      # S3 + DynamoDB
# розкоментуйте backend "s3"
terraform init -migrate-state
terraform apply                                 # VPC + ECR + EKS + Jenkins + Argo CD
```

> EKS + аддони + Helm-релізи піднімаються ~15–20 хв.

Доступ до кластера:

```bash
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

## 2. Перевірка Jenkins job

Адреса та пароль:

```bash
eval $(terraform output -raw jenkins_url_command)          # DNS балансувальника
terraform output -raw jenkins_admin_password_command | bash
```

Відкрийте `http://<jenkins-lb>:8080`, увійдіть (`admin` / пароль вище) і:

1. **Credentials → Add** → тип *Username with password*, `ID = github-token`,
   username = ваш GitHub-логін, password = GitHub PAT (scope `repo`).
   Kaniko пушить у ECR через IRSA-роль агента — окремих AWS-ключів не треба.
2. У [Jenkinsfile](Jenkinsfile) підставте свій `ECR_REGISTRY` (значення до `/` з
   `terraform output -raw ecr_repository_url`).
3. **New Item → Pipeline** → *Pipeline script from SCM* → Git →
   URL репозиторію, гілка `lesson-8-9`, *Script Path* = `lesson-8-9/Jenkinsfile`.
4. **Build Now**. Джоба: збере образ Kaniko → запушить у ECR → оновить `tag:` у
   `charts/django-app/values.yaml` → запушить у `main`.

## 3. Результат в Argo CD

Адреса та пароль:

```bash
eval $(terraform output -raw argocd_url_command)
terraform output -raw argocd_admin_password_command | bash
```

Відкрийте адресу Argo CD, увійдіть (`admin` / пароль вище). Application **django-app**
має бути `Synced` / `Healthy`. Після кожного білду Jenkins оновлює тег у Git —
Argo CD підхоплює комміт і автоматично викочує новий образ (`prune` + `selfHeal`).

Перевірити застосунок:

```bash
kubectl -n django get deploy,pods,svc,hpa,configmap
kubectl -n django get svc django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Важливі примітки

- **Гілка для Argo CD.** Application стежить за `main` (`git_target_revision`), а Jenkins
  туди ж пушить тег. Тому Helm-чарт `lesson-8-9/charts/django-app` має існувати на `main`
  (злийте `lesson-8-9` → `main`) або задайте `-var git_target_revision=lesson-8-9`.
- **ECR у values.yaml.** `image.repository` — заглушка з умовним account id; підставте
  реальний URL (`terraform output -raw ecr_repository_url`). Тег далі оновлює pipeline.
- **Вартість.** EKS + LoadBalancer-и + NAT платні. Після перевірки:

```bash
terraform destroy
```
