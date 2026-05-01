# Lesson 8-9 — CI/CD: Jenkins + Argo CD + Helm + Terraform

Повний CI/CD-процес для Django-застосунку на AWS EKS з використанням GitOps-підходу.

## Архітектура

```
Developer push → Jenkins (Kaniko build + ECR push) → Оновлення tag у values.yaml → Git push
                                                                                       │
Argo CD стежить за Git → Виявляє новий tag → Автоматична синхронізація в EKS кластер ◄──┘
```

## Структура проєкту

```
lesson-8-9/
├── main.tf                     # Підключення модулів (S3, VPC, ECR, EKS, Jenkins, Argo CD)
├── backend.tf                  # S3 + DynamoDB backend для Terraform state
├── outputs.tf                  # Outputs всіх ресурсів
├── providers.tf                # Провайдери AWS, Helm, Kubernetes
├── Jenkinsfile                 # CI-pipeline (build → push → update tag → git push)
│
├── charts/
│   └── django-app/             # Helm chart для Django (Argo CD синхронізує цей chart)
│       ├── Chart.yaml
│       ├── values.yaml         # image.tag оновлюється Jenkins-ом
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── hpa.yaml
│
└── modules/
    ├── s3-backend/             # S3 бакет + DynamoDB для state locking
    ├── vpc/                    # VPC, підмережі, IGW, NAT Gateway
    ├── ecr/                    # ECR репозиторій для Docker образів
    ├── eks/                    # EKS кластер + Node Group + EBS CSI Driver + OIDC
    ├── jenkins/                # Jenkins через Helm (JCasC, Kaniko, Git agent, RBAC)
    └── argo_cd/                # Argo CD через Helm + Application CRD
        ├── argocd.tf
        ├── variables.tf
        ├── providers.tf
        ├── values.yaml         # Конфігурація Argo CD (LoadBalancer, insecure mode)
        ├── outputs.tf
        └── charts/             # Локальний Helm chart для створення Application
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── application.yaml   # Argo CD Application (стежить за charts/django-app)
                └── repository.yaml    # Реєстрація Git-репозиторію в Argo CD
```

## Що створюється

| Компонент | Опис |
|-----------|------|
| S3 + DynamoDB | Terraform state backend з locking |
| VPC | 3 публічні + 3 приватні підмережі, IGW, NAT Gateway |
| ECR | Репозиторій `lesson-8-9-django` для Docker образів |
| EKS | Kubernetes кластер (t3.small, 1-3 ноди) + EBS CSI Driver |
| Jenkins | CI-сервер з Kubernetes-агентами (Kaniko + Git) |
| Argo CD | GitOps-контролер з автоматичною синхронізацією |
| Django App | Helm chart з Deployment, Service, HPA, ConfigMap |

## Передумови

- Terraform >= 1.0
- AWS CLI налаштований (`aws configure`)
- kubectl встановлений
- Права доступу: S3, DynamoDB, VPC, ECR, EKS, IAM

## Як запустити

### 1. Розгортання інфраструктури

```bash
cd lesson-8-9
terraform init
terraform plan
terraform apply
```

### 2. Налаштування kubectl

```bash
aws eks update-kubeconfig --name lesson-8-9-eks --region eu-central-1
```

### 3. Доступ до Jenkins

```bash
# URL Jenkins
kubectl get svc -n jenkins jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Пароль адміністратора
kubectl exec -n jenkins jenkins-0 -- cat /run/secrets/additional/chart-admin-password
```

**Налаштування Jenkins:**
1. Увійти як `admin` з отриманим паролем
2. Створити credentials `github-credentials` (Username + GitHub PAT з правами `repo`)
3. Створити Pipeline Job, вказавши Jenkinsfile: `lesson-8-9/Jenkinsfile`

### 4. Доступ до Argo CD

```bash
# URL Argo CD
kubectl get svc -n argocd argocd-argo-cd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Пароль адміністратора (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Argo CD Application `django-app` створюється автоматично і стежить за `lesson-8-9/charts/django-app` у гілці `main`.

## CI/CD Pipeline (Jenkinsfile)

| Stage | Контейнер | Дія |
|-------|-----------|-----|
| Build & Push Image | `kaniko` | Збірка Docker образу з `lesson-4_DockerProject/web/` та push до ECR |
| Update Helm Values | `git` | Оновлення `image.tag` у `charts/django-app/values.yaml` |
| Push to Git | `git` | Commit та push змін у `main` (з `[ci skip]` для запобігання циклу) |

Після push в Git, Argo CD автоматично виявляє зміну та синхронізує Django-застосунок у кластері.

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

## Знищення інфраструктури

```bash
terraform destroy
```
