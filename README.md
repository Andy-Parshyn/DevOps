# DevOps

Навчальний репозиторій з DevOps-практиками.

## Проєкти

- [`lesson-4_DockerProject/`](./lesson-4_DockerProject) — Dockerized Django + PostgreSQL + Nginx
- [`lesson-5_terraform/`](./lesson-5_terraform) — Terraform інфраструктура в AWS (S3 backend, DynamoDB lock, VPC, ECR)
- [`lesson-7/`](./lesson-7) — Terraform + AWS EKS + Helm chart для деплою Django в Kubernetes

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
