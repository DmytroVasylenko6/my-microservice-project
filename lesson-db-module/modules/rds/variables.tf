# Core Configuration
variable "use_aurora" {
  type        = bool
  description = "Set to true to create Aurora cluster, false for regular RDS instance"
  default     = false
}

variable "db_identifier" {
  type        = string
  description = "Identifier for the database instance or cluster"
  default     = "mydb"
}

variable "engine" {
  type        = string
  description = "Database engine: 'postgres' or 'mysql'"
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Engine must be either 'postgres' or 'mysql'."
  }
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
  default     = "15.4"
}

variable "instance_class" {
  type        = string
  description = "Instance class for RDS or Aurora (e.g., db.t3.medium, db.r5.large)"
  default     = "db.t3.medium"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for high availability"
  default     = false
}

# Database Configuration
variable "db_name" {
  type        = string
  description = "Name of the database to create"
  default     = "mydb"
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Master password for the database"
  sensitive   = true
}

variable "db_port" {
  type        = number
  description = "Port on which the database accepts connections"
  default     = 5432
}

# Network Configuration
variable "vpc_id" {
  type        = string
  description = "VPC ID where the database will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the database subnet group"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the database"
  default     = ["10.0.0.0/16"]
}

# Storage Configuration (for regular RDS)
variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB (only for regular RDS)"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum allocated storage in GB for autoscaling (only for regular RDS)"
  default     = 100
}

variable "storage_type" {
  type        = string
  description = "Storage type: gp2, gp3, io1, io2 (only for regular RDS)"
  default     = "gp3"
}

variable "storage_encrypted" {
  type        = bool
  description = "Enable storage encryption"
  default     = true
}

# Aurora Configuration
variable "aurora_cluster_instances" {
  type        = number
  description = "Number of Aurora cluster instances (only used when use_aurora = true)"
  default     = 2
  validation {
    condition     = var.aurora_cluster_instances >= 1 && var.aurora_cluster_instances <= 15
    error_message = "Aurora cluster instances must be between 1 and 15."
  }
}

# Parameter Group Configuration
variable "max_connections" {
  type        = string
  description = "Maximum number of database connections"
  default     = "100"
}

variable "log_statement" {
  type        = string
  description = "Log statement level for PostgreSQL (none, ddl, mod, all)"
  default     = "mod"
  validation {
    condition     = contains(["none", "ddl", "mod", "all"], var.log_statement)
    error_message = "log_statement must be one of: none, ddl, mod, all."
  }
}

variable "work_mem" {
  type        = string
  description = "Work memory for PostgreSQL in MB"
  default     = "4"
}

variable "general_log" {
  type        = string
  description = "Enable general log for MySQL (0 or 1)"
  default     = "0"
  validation {
    condition     = contains(["0", "1"], var.general_log)
    error_message = "general_log must be either '0' or '1'."
  }
}

variable "slow_query_log" {
  type        = string
  description = "Enable slow query log for MySQL (0 or 1)"
  default     = "1"
  validation {
    condition     = contains(["0", "1"], var.slow_query_log)
    error_message = "slow_query_log must be either '0' or '1'."
  }
}

# Backup Configuration
variable "backup_retention_period" {
  type        = number
  description = "Number of days to retain automated backups"
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  type        = string
  description = "Preferred backup window (UTC)"
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  type        = string
  description = "Preferred maintenance window (UTC)"
  default     = "mon:04:00-mon:05:00"
}

# Other Configuration
variable "publicly_accessible" {
  type        = bool
  description = "Make the database publicly accessible"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot when destroying"
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch. For PostgreSQL: postgresql, upgrade. For MySQL: audit, error, general, slowquery"
  default     = ["postgresql", "upgrade"]
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Enable Performance Insights (only for Aurora)"
  default     = false
}

variable "monitoring_interval" {
  type        = number
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

