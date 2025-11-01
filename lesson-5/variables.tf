variable "region" {
  type    = string
  default = "us-west-2"
}

variable "backend_bucket_name" {
  type        = string
  description = "S3 bucket name to store terraform state. Must be unique."
  default     = "REPLACE_ME_UNIQUE_BUCKET_NAME"
}

variable "backend_table_name" {
  type        = string
  description = "DynamoDB table name for terraform state locking"
  default     = "terraform-locks"
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
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  type    = string
  default = "lesson-5-vpc"
}

variable "ecr_name" {
  type    = string
  default = "lesson-5-ecr"
}

variable "ecr_scan_on_push" {
  type    = bool
  default = true
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "lesson-5"
    Env     = "dev"
    Owner   = "student"
  }
}
