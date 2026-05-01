# Lesson 10 — Універсальний RDS модуль (Aurora / Standalone)

Terraform-модуль для створення бази даних у AWS з підтримкою двох режимів: Aurora PostgreSQL Cluster або standalone RDS instance.

## Архітектура

```
VPC (10.0.0.0/16)
├── Private Subnets (3 AZ)
│   ├── DB Subnet Group
│   └── RDS Instance / Aurora Cluster
├── Security Group (port 5432 from VPC CIDR)
└── Parameter Group (max_connections, log_statement, work_mem)
```

## Структура проєкту

```
lesson-10/
├── main.tf                     # Підключення модулів (S3, VPC, ECR, EKS, Jenkins, Argo CD, RDS)
├── backend.tf                  # S3 + DynamoDB backend для Terraform state
├── variables.tf                # Змінна db_password (sensitive)
├── outputs.tf                  # Outputs всіх ресурсів включно з RDS
│
├── charts/
│   └── django-app/             # Helm chart для Django
│
└── modules/
    ├── s3-backend/             # S3 бакет + DynamoDB для state locking
    ├── vpc/                    # VPC, підмережі, IGW, NAT Gateway
    ├── ecr/                    # ECR репозиторій для Docker образів
    ├── eks/                    # EKS кластер + Node Group + EBS CSI Driver
    ├── jenkins/                # Jenkins через Helm
    ├── argo_cd/                # Argo CD через Helm + Application CRD
    └── rds/                    # Універсальний RDS модуль
        ├── variables.tf        # Змінні (use_aurora, engine, credentials, VPC params)
        ├── shared.tf           # Subnet Group, Security Group, Parameter Group
        ├── rds.tf              # Standalone RDS instance (count-based)
        ├── aurora.tf           # Aurora Cluster + writer instance (count-based)
        └── outputs.tf          # Endpoint, port, db_name, security_group_id
```

## Модуль RDS

### Режими роботи

| Параметр | `use_aurora = false` (default) | `use_aurora = true` |
|---|---|---|
| Ресурс БД | `aws_db_instance` | `aws_rds_cluster` + `aws_rds_cluster_instance` |
| Engine | `postgres` | `aurora-postgresql` (автоматично) |
| Multi-AZ | Через змінну `multi_az` | За замовчуванням (Aurora) |
| Storage | `allocated_storage` (gp3) | Managed (Aurora) |
| Мінімальний instance class | `db.t3.micro` | `db.t3.medium` |
| Parameter Group family | `postgres15` | `aurora-postgresql15` |

### Спільні ресурси (завжди створюються)

| Ресурс | Опис |
|--------|------|
| `aws_db_subnet_group` | Private subnets для розміщення БД |
| `aws_security_group` | Дозволяє порт 5432 з VPC CIDR |
| `aws_db_parameter_group` | max_connections=100, log_statement=all, work_mem=4096 |

### Змінні модуля

| Змінна | Тип | Default | Опис |
|--------|-----|---------|------|
| `identifier` | string | — | Ідентифікатор ресурсів |
| `use_aurora` | bool | `false` | Aurora Cluster або standalone RDS |
| `engine` | string | `"postgres"` | Engine БД |
| `engine_version` | string | `"15.4"` | Версія engine |
| `instance_class` | string | `"db.t3.micro"` | Клас інстансу |
| `allocated_storage` | number | `20` | Розмір диску в GB (тільки для RDS) |
| `multi_az` | bool | `false` | Multi-AZ (тільки для RDS) |
| `db_name` | string | `"appdb"` | Назва бази даних |
| `db_username` | string | `"dbadmin"` | Master username |
| `db_password` | string | — | Master password (sensitive) |
| `vpc_id` | string | — | ID VPC |
| `private_subnet_ids` | list(string) | — | ID приватних підмереж |
| `vpc_cidr_block` | string | — | CIDR блок VPC для Security Group |
| `parameter_group_family` | string | `""` | PG family (auto-derived якщо пусто) |
| `skip_final_snapshot` | bool | `true` | Пропустити final snapshot |
| `tags` | map(string) | `{}` | Додаткові теги |

### Outputs модуля

| Output | Опис |
|--------|------|
| `endpoint` | Endpoint для підключення до БД |
| `port` | Порт БД |
| `db_name` | Назва бази даних |
| `db_username` | Master username |
| `security_group_id` | ID Security Group |
| `reader_endpoint` | Aurora reader endpoint (пусто для standalone RDS) |

## Передумови

- Terraform >= 1.0
- AWS CLI налаштований (`aws configure`)
- kubectl встановлений
- Права доступу: S3, DynamoDB, VPC, ECR, EKS, IAM, RDS

## Як запустити

### 1. Розгортання інфраструктури

```bash
cd lesson-10
terraform init
terraform plan -var="db_password=YourSecurePassword123"
terraform apply -var="db_password=YourSecurePassword123"
```

### 2. Перемикання на Aurora

У `main.tf` змініть параметри модуля `rds`:

```hcl
module "rds" {
  source = "./modules/rds"

  identifier     = "lesson-10-db"
  use_aurora      = true                # Aurora Cluster
  instance_class  = "db.t3.medium"      # Мінімум для Aurora
  # ... решта параметрів без змін
}
```

### 3. Підключення до БД з EKS

```bash
# Отримати endpoint
terraform output rds_endpoint

# Підключення з pod у кластері
kubectl run pg-client --rm -it --image=postgres:15 -- \
  psql -h <endpoint> -U dbadmin -d appdb
```

## Outputs

| Output | Опис |
|--------|------|
| `s3_bucket_name` | Назва S3 бакета для Terraform state |
| `dynamodb_table_name` | Назва DynamoDB таблиці для locking |
| `vpc_id` | ID створеної VPC |
| `ecr_repository_url` | URL ECR репозиторію |
| `eks_cluster_name` | Назва EKS кластера |
| `eks_cluster_endpoint` | Endpoint EKS кластера |
| `jenkins_url` | Команда для отримання URL Jenkins |
| `jenkins_admin_password` | Команда для отримання пароля Jenkins |
| `argocd_url` | Команда для отримання URL Argo CD |
| `argocd_admin_password` | Команда для отримання пароля Argo CD |
| `rds_endpoint` | Endpoint бази даних |
| `rds_port` | Порт бази даних |
| `rds_db_name` | Назва бази даних |

## Знищення інфраструктури

```bash
terraform destroy -var="db_password=YourSecurePassword123"
```
