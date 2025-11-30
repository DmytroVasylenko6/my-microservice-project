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

variable "monitoring_namespace" {
  type        = string
  description = "Kubernetes namespace for monitoring"
  default     = "monitoring"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

