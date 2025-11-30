# Lesson DB Module: Універсальний Terraform модуль для RDS

Цей проєкт містить універсальний Terraform модуль для створення баз даних на AWS RDS, який підтримує як звичайні RDS instances, так і Aurora кластери.

## Особливості модуля

- ✅ **Універсальність**: Один модуль для звичайної RDS та Aurora кластера
- ✅ **Умовна логіка**: Автоматичне визначення типу БД через прапорець `use_aurora`
- ✅ **Автоматичне створення**: DB Subnet Group, Security Group, Parameter Group
- ✅ **Підтримка PostgreSQL та MySQL**: Для обох типів RDS та Aurora
- ✅ **Гнучкі налаштування**: Багато параметрів з розумними дефолтами
- ✅ **Production-ready**: Підтримка backup, encryption, monitoring та інше

## Структура проєкту

```
lesson-db-module/
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf              # Змінні Terraform
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   ├── vpc/                 # Модуль для VPC
│   └── rds/                 # Модуль для RDS
│       ├── shared.tf        # Спільні ресурси (Subnet Group, Security Group, Parameter Group)
│       ├── rds.tf           # Створення звичайної RDS instance
│       ├── aurora.tf        # Створення Aurora кластера
│       ├── variables.tf     # Змінні модуля
│       └── outputs.tf       # Виводи модуля
```

## Приклад використання модуля

### Приклад 1: Звичайна RDS PostgreSQL Instance

```hcl
module "rds" {
  source = "./modules/rds"

  use_aurora = false

  # Database identifier
  db_identifier = "my-postgres-db"

  # Database configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  multi_az       = false

  # Database credentials
  db_name     = "mydb"
  db_username = "admin"
  db_password = "SecurePassword123!"

  # Network configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  # Tags
  tags = {
    Project = "my-project"
    Env     = "dev"
  }
}
```

### Приклад 2: Aurora PostgreSQL Cluster

```hcl
module "rds" {
  source = "./modules/rds"

  use_aurora = true

  # Database identifier
  db_identifier = "my-aurora-cluster"

  # Database configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r5.large"
  multi_az       = true

  # Database credentials
  db_name     = "mydb"
  db_username = "admin"
  db_password = "SecurePassword123!"

  # Network configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # Aurora specific
  aurora_cluster_instances = 2

  # Tags
  tags = {
    Project = "my-project"
    Env     = "prod"
  }
}
```

### Приклад 3: MySQL RDS Instance

```hcl
module "rds" {
  source = "./modules/rds"

  use_aurora = false

  db_identifier = "my-mysql-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.medium"

  db_name     = "mydb"
  db_username = "admin"
  db_password = "SecurePassword123!"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Project = "my-project"
    Env     = "dev"
  }
}
```

## Опис змінних модуля

### Основні змінні

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `use_aurora` | `bool` | Створити Aurora кластер (`true`) або звичайну RDS (`false`) | `false` | Ні |
| `db_identifier` | `string` | Унікальний ідентифікатор БД | `"mydb"` | Ні |
| `engine` | `string` | Тип БД: `"postgres"` або `"mysql"` | `"postgres"` | Ні |
| `engine_version` | `string` | Версія движка БД | `"15.4"` | Ні |
| `instance_class` | `string` | Клас інстансу (напр., `db.t3.medium`, `db.r5.large`) | `"db.t3.medium"` | Ні |
| `multi_az` | `bool` | Увімкнути Multi-AZ для високої доступності | `false` | Ні |

### Налаштування бази даних

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `db_name` | `string` | Назва бази даних | `"mydb"` | Ні |
| `db_username` | `string` | Майстер-користувач | `"admin"` | Ні |
| `db_password` | `string` | Майстер-пароль | - | Так |
| `db_port` | `number` | Порт БД | `5432` (PostgreSQL) / `3306` (MySQL) | Ні |

### Мережеві налаштування

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `vpc_id` | `string` | ID VPC | - | Так |
| `private_subnet_ids` | `list(string)` | Список ID приватних підмереж | - | Так |
| `allowed_cidr_blocks` | `list(string)` | CIDR блоки з дозволом доступу | `["10.0.0.0/16"]` | Ні |
| `publicly_accessible` | `bool` | Зробити БД публічно доступною | `false` | Ні |

### Налаштування сховища (тільки для звичайної RDS)

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `allocated_storage` | `number` | Виділений обсяг у GB | `20` | Ні |
| `max_allocated_storage` | `number` | Максимальний обсяг для автопідвищення | `100` | Ні |
| `storage_type` | `string` | Тип сховища: `gp2`, `gp3`, `io1`, `io2` | `"gp3"` | Ні |
| `storage_encrypted` | `bool` | Шифрування сховища | `true` | Ні |

### Налаштування Aurora

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `aurora_cluster_instances` | `number` | Кількість інстансів у кластері (1-15) | `2` | Ні |

### Parameter Group налаштування

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `max_connections` | `string` | Максимальна кількість з'єднань | `"100"` | Ні |
| `log_statement` | `string` | Рівень логування для PostgreSQL (`none`, `ddl`, `mod`, `all`) | `"mod"` | Ні |
| `work_mem` | `string` | Робоча пам'ять для PostgreSQL (MB) | `"4"` | Ні |
| `general_log` | `string` | Увімкнути загальний лог для MySQL (`0` або `1`) | `"0"` | Ні |
| `slow_query_log` | `string` | Увімкнути лог повільних запитів для MySQL (`0` або `1`) | `"1"` | Ні |

### Налаштування резервного копіювання

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `backup_retention_period` | `number` | Кількість днів зберігання backup (0-35) | `7` | Ні |
| `backup_window` | `string` | Вікно резервного копіювання (UTC) | `"03:00-04:00"` | Ні |
| `maintenance_window` | `string` | Вікно обслуговування (UTC) | `"mon:04:00-mon:05:00"` | Ні |

### Інші налаштування

| Змінна | Тип | Опис | Дефолт | Обов'язкова |
|--------|-----|------|--------|-------------|
| `skip_final_snapshot` | `bool` | Пропустити фінальний snapshot при видаленні | `true` | Ні |
| `enabled_cloudwatch_logs_exports` | `list(string)` | Типи логів для CloudWatch | `["postgresql", "upgrade"]` | Ні |
| `deletion_protection` | `bool` | Захист від видалення | `false` | Ні |
| `performance_insights_enabled` | `bool` | Увімкнути Performance Insights (тільки Aurora) | `false` | Ні |
| `monitoring_interval` | `number` | Інтервал моніторингу (0, 1, 5, 10, 15, 30, 60) | `0` | Ні |

## Як змінити тип БД, engine, клас інстансу

### Зміна типу БД (RDS ↔ Aurora)

```hcl
# Для звичайної RDS
use_aurora = false

# Для Aurora кластера
use_aurora = true
```

### Зміна engine (PostgreSQL ↔ MySQL)

```hcl
# PostgreSQL
engine         = "postgres"
engine_version = "15.4"
db_port        = 5432

# MySQL
engine         = "mysql"
engine_version = "8.0"
db_port        = 3306
```

### Зміна класу інстансу

```hcl
# Для розробки (менші інстанси)
instance_class = "db.t3.micro"      # 1 vCPU, 1 GB RAM
instance_class = "db.t3.small"      # 2 vCPU, 2 GB RAM
instance_class = "db.t3.medium"     # 2 vCPU, 4 GB RAM

# Для production (більші інстанси)
instance_class = "db.r5.large"      # 2 vCPU, 16 GB RAM
instance_class = "db.r5.xlarge"    # 4 vCPU, 32 GB RAM
instance_class = "db.r5.2xlarge"   # 8 vCPU, 64 GB RAM

# Для Aurora використовуйте db.r5.* або db.r6g.*
instance_class = "db.r5.large"     # Aurora PostgreSQL/MySQL
instance_class = "db.r6g.large"    # Aurora PostgreSQL/MySQL (Graviton2)
```

## Використання модуля

### 1. Ініціалізація Terraform

```bash
cd lesson-db-module
terraform init
```

### 2. Налаштування змінних

Створіть файл `terraform.tfvars`:

```hcl
# Для звичайної RDS
use_aurora = false
db_engine  = "postgres"
db_instance_class = "db.t3.medium"
db_password = "YourSecurePassword123!"

# Або для Aurora
use_aurora = true
db_engine  = "postgres"
db_instance_class = "db.r5.large"
aurora_cluster_instances = 2
db_password = "YourSecurePassword123!"
```

### 3. Перевірка плану

```bash
terraform plan
```

### 4. Застосування змін

```bash
terraform apply
```

### 5. Перевірка виводів

```bash
# Для звичайної RDS
terraform output rds_endpoint
terraform output rds_port

# Для Aurora
terraform output aurora_cluster_endpoint
terraform output aurora_cluster_reader_endpoint
```

## Що створюється автоматично

Модуль автоматично створює:

1. **DB Subnet Group** - для розміщення БД у приватних підмережах
2. **Security Group** - з правилами доступу з вказаних CIDR блоків
3. **Parameter Group** - з базовими параметрами:
   - `max_connections` - максимальна кількість з'єднань
   - `log_statement` (PostgreSQL) - рівень логування
   - `work_mem` (PostgreSQL) - робоча пам'ять
   - `general_log` (MySQL) - загальний лог
   - `slow_query_log` (MySQL) - лог повільних запитів

## Приклади використання outputs

```hcl
# Отримання endpoint для підключення
output "database_endpoint" {
  value = module.rds.use_aurora ? module.rds.aurora_cluster_endpoint : module.rds.rds_endpoint
}

# Використання в іншому модулі
module "app" {
  source = "./modules/app"
  
  database_host = module.rds.use_aurora ? module.rds.aurora_cluster_endpoint : module.rds.rds_endpoint
  database_port = module.rds.database_port
  database_name = module.rds.database_name
}
```

## Рекомендації

### Для Development

```hcl
use_aurora = false
instance_class = "db.t3.micro"
multi_az = false
backup_retention_period = 1
deletion_protection = false
```

### Для Production

```hcl
use_aurora = true
instance_class = "db.r5.large"
multi_az = true
backup_retention_period = 30
deletion_protection = true
performance_insights_enabled = true
monitoring_interval = 60
```

## Troubleshooting

### Помилка: "InvalidParameterCombination"

Перевірте, що:
- Для Aurora не вказано `allocated_storage`
- Для звичайної RDS вказано `allocated_storage`
- `engine_version` відповідає `engine`

### Помилка: "DBSubnetGroupNotFoundFault"

Переконайтеся, що:
- `private_subnet_ids` містить принаймні 2 підмережі в різних AZ
- Підмережі знаходяться в правильній VPC

### Помилка: "InvalidParameterValue"

Перевірте:
- `aurora_cluster_instances` від 1 до 15
- `monitoring_interval` один з: 0, 1, 5, 10, 15, 30, 60
- `log_statement` один з: none, ddl, mod, all

## Видалення

```bash
terraform destroy
```

**Увага**: Якщо `skip_final_snapshot = false`, буде створено фінальний snapshot перед видаленням.

## Додаткові ресурси

- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [Terraform AWS Provider - RDS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [Terraform AWS Provider - Aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)

