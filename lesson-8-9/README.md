# Lesson 8-9: CI/CD з Jenkins + Argo CD

Цей проєкт реалізує повний CI/CD процес з використанням Jenkins, Helm, Terraform та Argo CD для автоматичного збирання, публікації Docker образів та розгортання застосунків у Kubernetes кластері.

## Архітектура CI/CD

```
┌─────────────┐
│   Git Repo  │
└──────┬──────┘
       │
       │ Push changes
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Jenkins   │────▶│  Amazon ECR  │────▶│  Git Repo   │
│  Pipeline   │     │  (Docker)    │     │ (Helm Chart)│
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                                │ Auto-sync
                                                ▼
                                         ┌─────────────┐
                                         │  Argo CD    │
                                         └──────┬──────┘
                                                │
                                                │ Deploy
                                                ▼
                                         ┌─────────────┐
                                         │  EKS Cluster│
                                         │  (K8s Pods)  │
                                         └─────────────┘
```

## Структура проєкту

```
lesson-8-9/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf              # Змінні Terraform
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                  # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf
│   │   └── aws_ebs_csi_driver.tf
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── argo_cd/             # Модуль для Helm-установки Argo CD
│       ├── argo_cd.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── variables.tf
│       ├── outputs.tf
│       └── charts/          # Helm-чарт для створення app'ів
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── templates/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── configmap.yaml
        │   └── hpa.yaml
        ├── Chart.yaml
        └── values.yaml
```

## Передумови

1. AWS CLI налаштований з відповідними credentials
2. Terraform >= 1.2.0
3. kubectl встановлений
4. Helm 3 встановлений
5. Git репозиторій з доступом для Jenkins та Argo CD

## Кроки виконання

### 1. Застосування Terraform

```bash
cd lesson-8-9

# Ініціалізація Terraform
terraform init

# Перевірка плану
terraform plan

# Застосування змін (створює VPC, ECR, EKS, Jenkins, Argo CD)
terraform apply
```

Після успішного застосування ви отримаєте:
- VPC з публічними та приватними підмережами
- ECR репозиторій для Docker образів
- EKS кластер з node group та EBS CSI Driver
- Jenkins встановлений через Helm
- Argo CD встановлений через Helm

### 2. Налаштування kubectl

```bash
# Отримайте команду з outputs
terraform output kubectl_config_command

# Або виконайте вручну
aws eks update-kubeconfig --region us-east-1 --name lesson-8-9-eks-cluster

# Перевірте підключення
kubectl get nodes
```

### 3. Отримання доступу до Jenkins

```bash
# Отримайте Jenkins URL та пароль
JENKINS_URL=$(terraform output -raw jenkins_url)
JENKINS_PASSWORD=$(terraform output -raw jenkins_admin_password)

echo "Jenkins URL: $JENKINS_URL"
echo "Jenkins Admin Password: $JENKINS_PASSWORD"
```

Відкрийте Jenkins URL у браузері та увійдіть:
- Username: `admin`
- Password: (значення з `jenkins_admin_password`)

### 4. Налаштування Jenkins Pipeline

1. У Jenkins перейдіть до **Manage Jenkins** → **Manage Plugins**
2. Переконайтеся, що встановлені плагіни:
   - Kubernetes
   - Git
   - Pipeline
   - Blue Ocean (опціонально)

3. Створіть новий Pipeline:
   - **New Item** → **Pipeline**
   - Назва: `django-app-pipeline`
   - У розділі **Pipeline**:
     - Definition: **Pipeline script from SCM**
     - SCM: **Git**
     - Repository URL: URL вашого Git репозиторію
     - Branch: `*/main` (або ваша гілка)
     - Script Path: `Jenkinsfile`

4. Налаштуйте змінні середовища (якщо потрібно):
   - **Manage Jenkins** → **Configure System** → **Global properties**
   - Додайте змінні:
     - `ECR_REPOSITORY`: (отримайте через `terraform output -raw ecr_repository_url`)
     - `GIT_REPO`: URL вашого Git репозиторію

### 5. Перевірка Jenkins Job

```bash
# Перевірте статус Jenkins подів
kubectl get pods -n jenkins

# Перевірте логи Jenkins
kubectl logs -n jenkins -l app.kubernetes.io/name=jenkins --tail=50

# Запустіть pipeline вручну через Jenkins UI або:
# Jenkins автоматично запустить pipeline при push до Git (якщо налаштовано webhook)
```

**Як перевірити Jenkins job:**

1. Відкрийте Jenkins UI
2. Перейдіть до **django-app-pipeline**
3. Натисніть **Build Now**
4. Перегляньте логи виконання
5. Перевірте, що:
   - Docker образ зібрано та завантажено до ECR
   - Helm chart оновлено з новим тегом
   - Зміни запушені до Git

### 6. Отримання доступу до Argo CD

```bash
# Отримайте Argo CD URL та пароль
ARGO_URL=$(terraform output -raw argo_cd_url)
ARGO_PASSWORD=$(terraform output -raw argo_cd_admin_password)

echo "Argo CD URL: $ARGO_URL"
echo "Argo CD Admin Password: $ARGO_PASSWORD"
```

Відкрийте Argo CD URL у браузері та увійдіть:
- Username: `admin`
- Password: (значення з `argo_cd_admin_password`)

### 7. Налаштування Argo CD Application

Argo CD Application створюється автоматично через Terraform. Перевірте:

```bash
# Перевірте Argo CD Application
kubectl get applications -n argocd

# Перевірте деталі
kubectl describe application django-app -n argocd
```

**Як побачити результат в Argo CD:**

1. Відкрийте Argo CD UI
2. Ви побачите Application **django-app**
3. Натисніть на нього для перегляду деталей
4. Перевірте статус синхронізації:
   - **Synced** - застосунок синхронізовано
   - **OutOfSync** - є зміни, які потребують синхронізації
5. Argo CD автоматично синхронізує зміни з Git репозиторію

### 8. Перевірка розгортання Django застосунку

```bash
# Перевірте поді
kubectl get pods -n default

# Перевірте сервіси
kubectl get svc -n default

# Отримайте LoadBalancer URL
kubectl get svc django-app -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Перевірте HPA
kubectl get hpa -n default

# Перевірте ConfigMap
kubectl get configmap -n default
```

## CI/CD Pipeline Процес

### Jenkins Pipeline (Jenkinsfile)

Pipeline виконує наступні кроки:

1. **Checkout** - отримує код з Git репозиторію
2. **Build and Push Docker Image** - збирає Docker образ за допомогою Kaniko та пушить до ECR
3. **Update Helm Chart** - оновлює тег образу в `values.yaml` та пушить зміни до Git

### Argo CD Sync

Argo CD автоматично:
1. Відстежує зміни в Git репозиторії
2. Виявляє оновлення Helm chart
3. Синхронізує зміни в Kubernetes кластер
4. Оновлює поді з новим образом

## Схема CI/CD

```
Developer Push → Git Repo
                    ↓
              Jenkins Webhook
                    ↓
         Jenkins Pipeline Triggered
                    ↓
         ┌──────────────────────┐
         │  1. Build Docker     │
         │  2. Push to ECR      │
         │  3. Update values.yaml│
         │  4. Push to Git      │
         └──────────────────────┘
                    ↓
              Git Updated
                    ↓
         Argo CD Detects Change
                    ↓
         ┌──────────────────────┐
         │  Auto Sync to K8s    │
         │  Deploy New Image    │
         └──────────────────────┘
                    ↓
            Application Updated
```

## Оновлення застосунку

Після зміни коду:

1. Зробіть commit та push до Git
2. Jenkins автоматично запустить pipeline (якщо налаштовано webhook)
3. Pipeline збере образ та оновить Helm chart
4. Argo CD автоматично синхронізує зміни

Або запустіть pipeline вручну через Jenkins UI.

## Troubleshooting

### Jenkins не може підключитися до кластера

```bash
# Перевірте ServiceAccount
kubectl get sa jenkins -n jenkins

# Перевірте IAM роль
kubectl describe sa jenkins -n jenkins
```

### Argo CD не синхронізує зміни

```bash
# Перевірте статус Application
kubectl get application django-app -n argocd -o yaml

# Перевірте логи Argo CD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50
```

### Проблеми з ECR доступом

```bash
# Перевірте IAM роль Jenkins
aws iam get-role --role-name lesson-8-9-eks-cluster-jenkins-role

# Перевірте політику
aws iam get-role-policy --role-name lesson-8-9-eks-cluster-jenkins-role --policy-name lesson-8-9-eks-cluster-jenkins-ecr-policy
```

## Видалення

```bash
# Видалити інфраструктуру
cd lesson-8-9
terraform destroy
```

## Додаткові ресурси

- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kaniko Documentation](https://github.com/GoogleContainerTools/kaniko)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

## Примітки

- Jenkins використовує Kubernetes agents (Kaniko + Git) для виконання pipeline
- Argo CD налаштований на автоматичну синхронізацію з Git
- EBS CSI Driver встановлено для підтримки persistent volumes
- Jenkins має IAM роль для доступу до ECR через IRSA (IAM Roles for Service Accounts)

