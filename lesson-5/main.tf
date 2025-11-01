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

# ECR module
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = var.ecr_name
  scan_on_push = var.ecr_scan_on_push
  tags        = var.common_tags
}
