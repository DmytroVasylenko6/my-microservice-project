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
  default = "lesson-8-9-vpc"
}

variable "ecr_name" {
  type    = string
  default = "lesson-8-9-ecr"
}

variable "ecr_scan_on_push" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type    = string
  default = "lesson-8-9-eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.28"
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_group_desired_size" {
  type    = number
  default = 2
}

variable "node_group_min_size" {
  type    = number
  default = 1
}

variable "node_group_max_size" {
  type    = number
  default = 4
}

variable "jenkins_namespace" {
  type    = string
  default = "jenkins"
}

variable "argo_namespace" {
  type    = string
  default = "argocd"
}

variable "git_repository_url" {
  type        = string
  description = "Git repository URL for Jenkins and Argo CD"
  default     = ""
}

variable "git_branch" {
  type        = string
  description = "Git branch to use"
  default     = "main"
}

variable "helm_chart_path" {
  type        = string
  description = "Path to Helm chart in Git repository"
  default     = "charts/django-app"
}

variable "jenkins_values" {
  type        = map(any)
  description = "Additional values for Jenkins Helm chart"
  default     = {}
}

variable "argo_values" {
  type        = map(any)
  description = "Additional values for Argo CD Helm chart"
  default     = {}
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "lesson-8-9"
    Env     = "dev"
    Owner   = "student"
  }
}

