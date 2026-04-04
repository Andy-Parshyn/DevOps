# Lesson 5 — Terraform Infrastructure

## Опис проєкту

Цей проєкт розгортає базову хмарну інфраструктуру в AWS за допомогою Terraform з використанням модульної архітектури. Стан Terraform зберігається у S3 з блокуванням через DynamoDB.

## Структура проєкту

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

## Модулі

### s3-backend
Створює інфраструктуру для зберігання Terraform state:
- S3 бакет з увімкненим версіонуванням
- Контроль власності об'єктів (BucketOwnerEnforced)
- DynamoDB таблиця для блокування state файлів

### vpc
Створює мережеву інфраструктуру:
- VPC з CIDR блоком `10.0.0.0/16`
- 3 публічні підмережі (eu-central-1a, 1b, 1c)
- 3 приватні підмережі (eu-central-1a, 1b, 1c)
- Internet Gateway для публічних підмереж
- NAT Gateway + Elastic IP для приватних підмереж
- Route Tables та асоціації для обох типів підмереж

### ecr
Створює репозиторій для Docker образів:
- ECR репозиторій з автоматичним скануванням образів
- Lifecycle policy — зберігає останні 10 образів

## Вимоги

- Terraform >= 1.0
- AWS CLI налаштований (`aws configure`)
- Права доступу: S3, DynamoDB, VPC, ECR

## Команди

```bash
# Ініціалізація провайдерів та модулів
terraform init

# Перегляд плану змін
terraform plan

# Застосування інфраструктури
terraform apply

# Знищення всіх ресурсів
terraform destroy
```

## Outputs

| Назва | Опис |
|-------|------|
| `s3_bucket_name` | Назва S3 бакета для Terraform state |
| `dynamodb_table_name` | Назва DynamoDB таблиці для блокування |
| `vpc_id` | ID створеного VPC |
| `public_subnet_ids` | ID публічних підмереж |
| `private_subnet_ids` | ID приватних підмереж |
| `ecr_repository_url` | URL ECR репозиторію |

## Важливо

Після завершення роботи знищуй ресурси щоб уникнути зайвих витрат:

```bash
terraform destroy
```
