# Lesson 7: Kubernetes Cluster на AWS EKS

Цей проєкт містить Terraform конфігурацію для створення Kubernetes кластера на AWS EKS та Helm chart для розгортання Django застосунку.

## Структура проєкту

```
lesson-7/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf             # Змінні Terraform
├── outputs.tf              # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   ├── ecr/                 # Модуль для ECR
│   └── eks/                 # Модуль для Kubernetes кластера
│
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── templates/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── configmap.yaml
        │   ├── hpa.yaml
        │   └── serviceaccount.yaml
        ├── Chart.yaml
        └── values.yaml
```

## Передумови

1. AWS CLI налаштований з відповідними credentials
2. Terraform >= 1.2.0
3. kubectl встановлений
4. Helm 3 встановлений
5. Docker встановлений

## Кроки виконання

### 1. Створення інфраструктури через Terraform

```bash
cd lesson-7

# Ініціалізація Terraform
terraform init

# Перевірка плану
terraform plan

# Застосування змін
terraform apply
```

Після успішного застосування ви отримаєте:
- VPC з публічними та приватними підмережами
- ECR репозиторій для Docker образів
- EKS кластер з node group

### 2. Налаштування kubectl

Після створення кластера налаштуйте kubectl:

```bash
# Отримайте команду з outputs
terraform output kubectl_config_command

# Або виконайте вручну
aws eks update-kubeconfig --region us-east-1 --name lesson-7-eks-cluster
```

Перевірте підключення:
```bash
kubectl get nodes
```

### 3. Завантаження Docker образу до ECR

```bash
# Отримайте ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Авторизація в ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Побудуйте образ (якщо ще не побудовано)
cd ../web
docker build -t django-app:latest .

# Тегуйте образ для ECR
docker tag django-app:latest $ECR_URL:latest

# Завантажте образ до ECR
docker push $ECR_URL:latest
```

### 4. Розгортання застосунку через Helm

```bash
cd ../charts/django-app

# Оновіть values.yaml з ECR URL
# Встановіть image.repository на значення з terraform output ecr_repository_url

# Встановіть Helm chart
helm install django-app . \
  --set image.repository=$(cd ../../lesson-7 && terraform output -raw ecr_repository_url) \
  --set image.tag=latest

# Або використайте файл values.yaml з оновленим repository URL
helm install django-app . -f values.yaml
```

### 5. Перевірка розгортання

```bash
# Перевірте поді
kubectl get pods

# Перевірте сервіси
kubectl get svc

# Отримайте LoadBalancer URL
kubectl get svc django-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Перевірте HPA
kubectl get hpa

# Перевірте ConfigMap
kubectl get configmap
kubectl describe configmap django-app-config
```

## Компоненти Helm Chart

### Deployment
- Використовує образ з ECR
- Підключає ConfigMap через `envFrom`
- Налаштовані liveness та readiness проби
- Ресурсні обмеження (CPU та пам'ять)

### Service
- Тип: LoadBalancer для зовнішнього доступу
- Порт: 80 -> 8000 (container port)

### HPA (Horizontal Pod Autoscaler)
- Мінімальна кількість подів: 2
- Максимальна кількість подів: 6
- Масштабування при CPU > 70% або Memory > 70%

### ConfigMap
- Містить змінні середовища для Django
- Підключається до подів через `envFrom`

## Оновлення застосунку

```bash
# Побудуйте новий образ
cd ../web
docker build -t django-app:v2 .

# Тегуйте та завантажте
docker tag django-app:v2 $ECR_URL:v2
docker push $ECR_URL:v2

# Оновіть Helm release
helm upgrade django-app ../charts/django-app \
  --set image.tag=v2
```

## Видалення

```bash
# Видалити Helm release
helm uninstall django-app

# Видалити інфраструктуру
cd lesson-7
terraform destroy
```

## Змінні середовища

Змінні середовища налаштовуються в `charts/django-app/values.yaml` в секції `configMap.data`:

- `DATABASE_NAME` - назва бази даних
- `DATABASE_USER` - користувач бази даних
- `DATABASE_PASSWORD` - пароль бази даних
- `DATABASE_HOST` - хост бази даних
- `DATABASE_PORT` - порт бази даних
- `DEBUG` - режим налагодження Django
- `ALLOWED_HOSTS` - дозволені хости

## Примітки

- EKS кластер створюється в приватних підмережах для безпеки
- Node group використовує t3.medium інстанси (можна змінити в variables.tf)
- HPA налаштований на масштабування від 2 до 6 подів
- ConfigMap автоматично підключається до всіх подів через envFrom

