# Final Project — AWS Infrastructure (EKS + Jenkins + Argo CD + Prometheus/Grafana)

Консолідація всіх попередніх уроків у єдину Terraform-інфраструктуру з повним AWS-стеком: VPC, ECR, EKS, RDS, Jenkins, Argo CD та новим модулем моніторингу (Prometheus + Grafana через `kube-prometheus-stack`). Django-застосунок переміщено у `final-project/Django/` з flat layout, Helm chart живе у `final-project/charts/django-app`, GitOps-шлях оновлено для Argo CD.

## Архітектура

```
VPC (10.0.0.0/16) — 3 AZ
├── Public Subnets   → IGW, NAT Gateway
├── Private Subnets
│   ├── EKS Node Group (managed)
│   ├── DB Subnet Group → RDS / Aurora PostgreSQL
│   └── Monitoring (3 AZ)
│       └── kube-prometheus-stack
│           ├── Prometheus
│           ├── Grafana
│           ├── Alertmanager
│           ├── node-exporter (DaemonSet)
│           └── kube-state-metrics
├── ECR (lesson-10-django)
├── Jenkins (Helm) — Kaniko build → ECR push → Git update
└── Argo CD (Helm) — sync final-project/charts/django-app → EKS
```

## Структура проєкту

```
final-project/
├── main.tf                     # Підключення модулів (S3, VPC, ECR, EKS, RDS, Jenkins, Argo CD, Monitoring)
├── backend.tf                  # S3 + DynamoDB backend (key=final-project/terraform.tfstate)
├── providers.tf                # AWS, Helm, Kubernetes providers
├── variables.tf                # db_password, jenkins_admin_password, grafana_admin_password
├── outputs.tf                  # Outputs усіх модулів + monitoring URLs
│
├── Django/                     # Django-застосунок (flat layout)
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   ├── docker-compose.yaml
│   ├── Jenkinsfile             # CI: Kaniko → ECR → values.yaml → Git push
│   ├── myproject/              # settings.py, urls.py, wsgi.py
│   └── nginx/                  # nginx.conf для local docker-compose
│
├── charts/
│   └── django-app/             # Helm chart (Argo CD target)
│
└── modules/
    ├── s3-backend/             # S3 + DynamoDB для state locking
    ├── vpc/                    # VPC, підмережі, IGW, NAT Gateway
    ├── ecr/                    # ECR репозиторій lesson-10-django
    ├── eks/
    │   ├── eks.tf              # EKS cluster + Node Group
    │   └── aws_ebs_csi_driver.tf  # OIDC provider + IRSA + EBS CSI addon
    ├── rds/                    # Aurora / standalone RDS PostgreSQL
    ├── jenkins/                # Jenkins (Helm) + JCasC + Kaniko
    ├── argo_cd/                # Argo CD (Helm) + Application CRD
    └── monitoring/             # kube-prometheus-stack (новий)
        ├── monitoring.tf
        ├── values.yaml
        ├── providers.tf
        ├── variables.tf
        └── outputs.tf
```

## Модулі

| Модуль | Опис |
|--------|------|
| `s3-backend` | S3 бакет (versioning) + DynamoDB таблиця для Terraform state locking |
| `vpc` | VPC 10.0.0.0/16 з публічними та приватними підмережами в 3 AZ, IGW, NAT Gateway |
| `ecr` | ECR репозиторій `lesson-10-django` для Docker-образів Django-застосунку |
| `eks` | EKS-кластер + managed Node Group + OIDC provider + EBS CSI Driver (IRSA). EBS CSI винесено у `aws_ebs_csi_driver.tf` |
| `rds` | Універсальний модуль PostgreSQL: standalone RDS instance або Aurora Cluster через `use_aurora` |
| `jenkins` | Jenkins через Helm з Kubernetes-агентами (Kaniko + Git), JCasC, RBAC |
| `argo_cd` | Argo CD через Helm + Application CRD, GitOps-шлях `final-project/charts/django-app` |
| `monitoring` | `kube-prometheus-stack` через Helm: Grafana + Prometheus + Alertmanager + node-exporter + kube-state-metrics. Усі сервіси ClusterIP (доступ через port-forward) |

## Змінні

| Змінна | Тип | Опис |
|--------|-----|------|
| `db_password` | string (sensitive) | Master password для RDS / Aurora PostgreSQL |
| `jenkins_admin_password` | string (sensitive) | Пароль адміна Jenkins (JCasC) |
| `grafana_admin_password` | string (sensitive) | Пароль адміна Grafana (`admin/<value>`) |

## Передумови

- Terraform >= 1.0
- AWS CLI налаштований (`aws configure`)
- kubectl встановлений
- Helm >= 3.x
- Права доступу: S3, DynamoDB, VPC, ECR, EKS, IAM, RDS

## Як запустити

```bash
cd final-project
terraform init
terraform plan -var="db_password=YourSecurePassword123" -var="jenkins_admin_password=AdminPass123" -var="grafana_admin_password=GrafanaPass123"
terraform apply -var="db_password=YourSecurePassword123" -var="jenkins_admin_password=AdminPass123" -var="grafana_admin_password=GrafanaPass123"
```

Налаштування kubectl після apply:

```bash
aws eks update-kubeconfig --region eu-central-1 --name lesson-10-eks
```

## Доступ

### Smoke-test усіх трьох namespace

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

### Port-forward UI

```bash
# Jenkins (http://localhost:8080)
kubectl port-forward svc/jenkins 8080:8080 -n jenkins

# Argo CD (https://localhost:8081)
kubectl port-forward svc/argocd-server 8081:443 -n argocd

# Grafana (http://localhost:3000, user: admin)
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```

### Перевірка моніторингу

Після відкриття Grafana переконайся, що вбудований дашборд **Kubernetes / Compute Resources / Cluster** показує дані (CPU, Memory, Pods). Це підтверджує, що Prometheus отримує метрики від `node-exporter` і `kube-state-metrics`.

### Отримання паролів через outputs

```bash
# Jenkins admin password
$(terraform output -raw jenkins_admin_password)

# Argo CD admin password
$(terraform output -raw argocd_admin_password)

# Grafana admin password
$(terraform output -raw grafana_admin_password_command)
```

## Django-застосунок

Джерела Django живуть у [`final-project/Django/`](./Django/) з flat layout:

- `Dockerfile`, `manage.py`, `requirements.txt`, `myproject/` — на одному рівні
- `nginx/` — конфіг nginx для локального docker-compose (reverse proxy)
- `docker-compose.yaml` — локальний запуск (web + db + nginx)
- `Jenkinsfile` — CI-пайплайн, який Kaniko підхоплює під час білда

ECR репозиторій залишається `lesson-10-django` (resource naming не змінювали). Argo CD стежить за гілкою репозиторію та шляхом `final-project/charts/django-app` — Jenkinsfile після білда оновлює `image.tag` у `values.yaml` і пушить у Git, після чого Argo CD синхронізує деплоймент в EKS.

## Outputs

| Output | Опис |
|--------|------|
| `s3_bucket_name` | Назва S3 бакета для Terraform state |
| `dynamodb_table_name` | Назва DynamoDB таблиці для locking |
| `vpc_id` | ID створеної VPC |
| `ecr_repository_url` | URL ECR репозиторію |
| `eks_cluster_name` | Назва EKS-кластера |
| `eks_cluster_endpoint` | Endpoint EKS-кластера |
| `jenkins_url_command` | Команда port-forward для Jenkins |
| `jenkins_admin_password` | Команда отримання пароля Jenkins |
| `argocd_url_command` | Команда port-forward для Argo CD |
| `argocd_admin_password` | Команда отримання пароля Argo CD |
| `rds_endpoint` | Endpoint бази даних |
| `rds_port` | Порт бази даних |
| `rds_db_name` | Назва бази даних |
| `grafana_url_command` | Команда port-forward для Grafana |
| `prometheus_url_command` | Команда port-forward для Prometheus |
| `grafana_admin_password_command` | Команда отримання пароля Grafana з Kubernetes Secret |

## Знищення інфраструктури

```bash
terraform destroy -var="db_password=YourSecurePassword123" -var="jenkins_admin_password=AdminPass123" -var="grafana_admin_password=GrafanaPass123"
```

> Зверни увагу: усі три `-var=` прапори обовʼязкові і для `apply`, і для `destroy` — інакше Terraform зупиниться на запиті відсутньої змінної.
