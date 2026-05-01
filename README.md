# DevOps

Навчальний репозиторій з DevOps-практиками.

## Проєкти

- [`lesson-4_DockerProject/`](./lesson-4_DockerProject) — Dockerized Django + PostgreSQL + Nginx
- [`lesson-5_terraform/`](./lesson-5_terraform) — Terraform інфраструктура в AWS (S3 backend, DynamoDB lock, VPC, ECR)
- [`lesson-7/`](./lesson-7) — Terraform + AWS EKS + Helm chart для деплою Django в Kubernetes
- [`lesson-8-9/`](./lesson-8-9) — CI/CD pipeline: Jenkins + Argo CD + Helm + Terraform на EKS
- [`lesson-10/`](./lesson-10) — Універсальний RDS модуль: Aurora Cluster або standalone RDS instance

---

## Lesson 4 — DockerProject

Мінімальний Django-проєкт, розгорнутий у Docker Compose з трьома сервісами:

| Сервіс | Образ | Призначення |
|--------|-------|-------------|
| `web`  | Python 3.11 + Django | Django-застосунок |
| `db`   | PostgreSQL 15 | База даних |
| `nginx`| Nginx | Reverse proxy (порт 80) |

### Структура

```
lesson-4_DockerProject/
├── docker-compose.yml
├── .env                  # змінні середовища (не в git)
├── .env.example          # шаблон змінних
├── web/
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   └── myproject/
│       ├── settings.py
│       ├── urls.py
│       └── wsgi.py
└── nginx/
    └── nginx.conf
```

### Як запустити

**1. Перейди в директорію проєкту:**

```bash
cd lesson-4_DockerProject
```

**2. Скопіюй файл змінних середовища та за потреби відредагуй:**

```bash
cp .env.example .env
```

**3. Запусти контейнери:**

```bash
docker compose up --build
```

**4. У новому терміналі виконай міграції:**

```bash
docker compose exec web python manage.py migrate
```

**5. (Опційно) Створи суперкористувача для адмін-панелі:**

```bash
docker compose exec web python manage.py createsuperuser
```

### Доступ

| URL | Опис |
|-----|------|
| `http://localhost/` | Django через Nginx |
| `http://localhost/admin/` | Адмін-панель Django |
| `http://localhost:8000/` | Django напряму (без Nginx) |

### Зупинити

```bash
docker compose down
```

Щоб також видалити дані бази даних:

```bash
docker compose down -v
```

---

## Lesson 5 — Terraform Infrastructure

Проєкт для розгортання базової AWS інфраструктури за допомогою Terraform з модульною структурою.

### Що створюється

- S3 бакет для Terraform state (з versioning)
- DynamoDB таблиця для state locking
- VPC з публічними та приватними підмережами
- ECR репозиторій для Docker образів

### Структура

```text
lesson-5_terraform/
├── main.tf
├── backend.tf
├── outputs.tf
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   └── ecr/
└── README.md
```

### Передумови

- Terraform >= 1.0
- Налаштований AWS CLI (`aws configure`)
- Права доступу до S3, DynamoDB, VPC, ECR

### Як запустити

```bash
cd lesson-5_terraform
terraform init -reconfigure
terraform plan
terraform apply
```

### Корисні команди

```bash
terraform output
terraform destroy
```

### Основні outputs

- `s3_bucket_name`
- `dynamodb_table_name`
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `ecr_repository_url`

---

## Lesson 7 — Terraform + EKS + Helm

Розширення Terraform-проєкту для Kubernetes-розгортання Django в AWS EKS.

### Що додано у Lesson 7

- модуль `eks` для створення EKS кластера та node group
- Helm chart `charts/django-app` для деплою Django, Service і HPA
- оновлений Terraform stack із outputs для EKS endpoint та назви кластера
- S3 backend для зберігання state (`lesson-7/terraform.tfstate`)

### Основні компоненти

- `modules/s3-backend` — S3 + lock-механізм
- `modules/vpc` — мережа (публічні/приватні підмережі)
- `modules/ecr` — ECR репозиторій для Docker image
- `modules/eks` — EKS cluster + managed node group
- `charts/django-app` — Helm chart (Deployment, Service, ConfigMap, HPA)

### Документація

Детальна інструкція для Lesson 7: [`lesson-7/README.md`](./lesson-7/README.md)

---

## Lesson 8-9 — CI/CD: Jenkins + Argo CD + Helm + Terraform

Повний CI/CD-процес для Django-застосунку з використанням GitOps-підходу.

### Архітектура

```
Developer push → Jenkins (Kaniko build + ECR push) → Оновлення tag у values.yaml → Git push
                                                                                       │
Argo CD стежить за Git → Виявляє новий tag → Автоматична синхронізація в EKS кластер ◄──┘
```

### Що додано у Lesson 8-9

- модуль `jenkins` — Jenkins через Helm з Kubernetes-агентами (Kaniko + Git)
- модуль `argo_cd` — Argo CD через Helm з автоматичною синхронізацією
- `Jenkinsfile` — CI-pipeline (build → push ECR → update values → push to Git)
- Helm chart `charts/django-app` — для деплою Django через Argo CD
- EBS CSI Driver + OIDC provider для IRSA в EKS модулі

### Основні компоненти

- `modules/s3-backend` — S3 + DynamoDB для Terraform state
- `modules/vpc` — VPC з публічними/приватними підмережами
- `modules/ecr` — ECR репозиторій для Docker образів
- `modules/eks` — EKS кластер + EBS CSI Driver + OIDC
- `modules/jenkins` — Jenkins (Helm) з JCasC, Kaniko, RBAC
- `modules/argo_cd` — Argo CD (Helm) + Application CRD для django-app
- `charts/django-app` — Helm chart (Deployment, Service, ConfigMap, HPA)

### Документація

Детальна інструкція для Lesson 8-9: [`lesson-8-9/README.md`](./lesson-8-9/README.md)

---

## Lesson 10 — Універсальний RDS модуль (Aurora / Standalone)

Terraform-модуль для створення бази даних у AWS з підтримкою двох режимів роботи через змінну `use_aurora`.

### Що додано у Lesson 10

- модуль `rds` — універсальний модуль для RDS та Aurora PostgreSQL
- автоматичне створення DB Subnet Group, Security Group, Parameter Group
- умовне створення ресурсів через `count` на основі `use_aurora`
- параметри БД (max_connections, log_statement, work_mem) через Parameter Group

### Режими роботи

| `use_aurora` | Що створюється |
|---|---|
| `false` (default) | `aws_db_instance` — одна standalone RDS instance |
| `true` | `aws_rds_cluster` + `aws_rds_cluster_instance` (writer) — Aurora Cluster |

### Основні компоненти

- `modules/rds/shared.tf` — DB Subnet Group, Security Group, Parameter Group (спільні для обох режимів)
- `modules/rds/rds.tf` — standalone RDS instance (`count = use_aurora ? 0 : 1`)
- `modules/rds/aurora.tf` — Aurora Cluster + writer (`count = use_aurora ? 1 : 0`)
- Усі попередні модулі: S3, VPC, ECR, EKS, Jenkins, Argo CD

### Документація

Детальна інструкція для Lesson 10: [`lesson-10/README.md`](./lesson-10/README.md)
