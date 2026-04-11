# Lesson 7 — Terraform + AWS EKS + Helm (Django)

## Опис

Цей урок додає Kubernetes-рівень до попередньої інфраструктури:
- Terraform створює AWS ресурси (S3 backend, VPC, ECR, EKS).
- Helm chart деплоїть Django застосунок у EKS.
- HPA автоматично масштабує pod-и за CPU.

## Структура

```text
lesson-7/
├── main.tf
├── backend.tf
├── outputs.tf
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── configmap.yaml
│           ├── deployment.yaml
│           ├── hpa.yaml
│           └── service.yaml
└── modules/
    ├── s3-backend/
    ├── vpc/
    ├── ecr/
    └── eks/
```

## Що створює Terraform

- S3 bucket + locking для Terraform state
- VPC з публічними та приватними підмережами
- ECR репозиторій `lesson-7-django`
- EKS кластер `lesson-7-eks`
- EKS managed node group (`t3.small`, autoscaling 1..3, desired 2)

## Передумови

- Terraform >= 1.0
- AWS CLI налаштований (`aws configure`)
- `kubectl` встановлений
- Helm 3 встановлений
- IAM права для EKS, VPC, EC2, IAM, ECR, S3, DynamoDB

## Запуск Terraform

```bash
cd lesson-7
terraform init -reconfigure
terraform plan
terraform apply
```

Після `apply` перевір outputs:

```bash
terraform output
```

Ключові outputs:
- `s3_bucket_name`
- `dynamodb_table_name`
- `vpc_id`
- `ecr_repository_url`
- `eks_cluster_name`
- `eks_cluster_endpoint`

## Підключення до EKS

```bash
aws eks update-kubeconfig --region eu-central-1 --name lesson-7-eks
kubectl get nodes
```

## Helm деплой Django

1. Переконайся, що в ECR є image для застосунку.
2. За потреби онови `charts/django-app/values.yaml`:
   - `image.repository`
   - `image.tag`
   - `config.*` (змінні застосунку)
3. Встанови або онови реліз:

```bash
helm upgrade --install django-app ./charts/django-app
```

Перевірка:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

## Важливі нотатки

- У chart Service має тип `LoadBalancer`, тому AWS створить зовнішній endpoint.
- `DJANGO_ALLOWED_HOSTS` за замовчуванням встановлено у `*` лише для навчального середовища.
- `POSTGRES_HOST` у `values.yaml` вказаний як `db`; для EKS це зазвичай потребує окремого сервісу БД або зовнішньої managed БД.

## Очистка ресурсів

```bash
helm uninstall django-app
terraform destroy
```
