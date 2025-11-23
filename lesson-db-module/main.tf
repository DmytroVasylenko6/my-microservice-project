terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

# S3 backend module
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.backend_bucket_name
  table_name  = var.backend_table_name
  region      = var.region
  tags        = var.common_tags
}

# VPC module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = var.vpc_name
  tags               = var.common_tags
}

# RDS module
module "rds" {
  source = "./modules/rds"

  use_aurora = var.use_aurora

  # Database identifier
  db_identifier = "${var.vpc_name}-db"

  # Database configuration
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  multi_az       = var.db_multi_az

  # Database credentials
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  # Network configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = var.allowed_cidr_blocks

  # Aurora specific (ignored if use_aurora = false)
  aurora_cluster_instances = var.aurora_cluster_instances

  # Tags
  tags = var.common_tags
}

