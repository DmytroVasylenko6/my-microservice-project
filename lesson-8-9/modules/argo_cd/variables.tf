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

variable "git_path" {
  type        = string
  description = "Path to Helm chart in Git repository"
  default     = "charts/django-app"
}

variable "argo_namespace" {
  type        = string
  description = "Kubernetes namespace for Argo CD"
  default     = "argocd"
}

variable "argo_values" {
  type        = map(any)
  description = "Additional values for Argo CD Helm chart"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

