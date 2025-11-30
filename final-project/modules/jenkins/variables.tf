variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_ca_cert" {
  type        = string
  description = "EKS cluster CA certificate"
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "EKS cluster OIDC issuer URL"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "git_repository_url" {
  type        = string
  description = "Git repository URL"
  default     = ""
}

variable "git_branch" {
  type        = string
  description = "Git branch"
  default     = "main"
}

variable "jenkins_namespace" {
  type        = string
  description = "Kubernetes namespace for Jenkins"
  default     = "jenkins"
}

variable "jenkins_values" {
  type        = map(any)
  description = "Additional values for Jenkins Helm chart"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

