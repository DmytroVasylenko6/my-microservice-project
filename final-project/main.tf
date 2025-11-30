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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
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

# RDS module
module "rds" {
  source = "./modules/rds"

  use_aurora = var.use_aurora

  db_identifier = "${var.vpc_name}-db"

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  multi_az       = var.db_multi_az

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = var.allowed_cidr_blocks

  aurora_cluster_instances = var.aurora_cluster_instances

  tags = var.common_tags
}

# Jenkins module
module "jenkins" {
  source = "./modules/jenkins"
  
  depends_on = [module.eks]
  
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_name            = module.eks.cluster_name
  cluster_ca_cert         = module.eks.cluster_certificate_authority_data
  cluster_oidc_issuer_url  = module.eks.cluster_oidc_issuer_url
  
  ecr_repository_url  = module.ecr.repository_url
  ecr_repository_name = module.ecr.repository_name
  
  git_repository_url = var.git_repository_url
  git_branch        = var.git_branch
  
  jenkins_namespace = var.jenkins_namespace
  jenkins_values    = var.jenkins_values
  
  tags = var.common_tags
}

# Argo CD module
module "argo_cd" {
  source = "./modules/argo_cd"
  
  depends_on = [module.eks]
  
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_name     = module.eks.cluster_name
  cluster_ca_cert  = module.eks.cluster_certificate_authority_data
  
  git_repository_url = var.git_repository_url
  git_branch        = var.git_branch
  git_path          = var.helm_chart_path
  
  argo_namespace = var.argo_namespace
  argo_values    = var.argo_values
  
  tags = var.common_tags
}

# Monitoring module (Prometheus + Grafana)
module "monitoring" {
  source = "./modules/monitoring"
  
  depends_on = [module.eks]
  
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_name     = module.eks.cluster_name
  cluster_ca_cert  = module.eks.cluster_certificate_authority_data
  
  monitoring_namespace = var.monitoring_namespace
  
  tags = var.common_tags
}

