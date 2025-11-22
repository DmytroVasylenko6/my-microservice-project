terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
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

# EKS module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  
  tags = var.common_tags
}

