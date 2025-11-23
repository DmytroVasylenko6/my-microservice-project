variable "region" {
  type    = string
  default = "us-east-1"
}

variable "backend_bucket_name" {
  type        = string
  description = "S3 bucket name to store terraform state. Must be unique."
  default     = "picsio-bucket-626bb381c1ab654dc35b8adb-us-east-1"
}

variable "backend_table_name" {
  type        = string
  description = "DynamoDB table name for terraform state locking"
  default     = "use_lockfile"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_name" {
  type    = string
  default = "lesson-db-module-vpc"
}

# RDS Module Variables
variable "use_aurora" {
  type        = bool
  description = "Set to true to create Aurora cluster, false for regular RDS instance"
  default     = false
}

variable "db_engine" {
  type        = string
  description = "Database engine (postgres, mysql, etc.)"
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "15.4"
}

variable "db_instance_class" {
  type        = string
  description = "Instance class for RDS or Aurora"
  default     = "db.t3.medium"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}

variable "db_name" {
  type        = string
  description = "Name of the database"
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
  default     = "ChangeMe123!"
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the database"
  default     = ["10.0.0.0/16"]
}

variable "aurora_cluster_instances" {
  type        = number
  description = "Number of Aurora cluster instances (only used when use_aurora = true)"
  default     = 2
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "lesson-db-module"
    Env     = "dev"
    Owner   = "student"
  }
}

