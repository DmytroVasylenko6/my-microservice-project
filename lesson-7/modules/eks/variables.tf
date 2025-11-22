variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.28"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the cluster will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the cluster"
}

variable "node_group_instance_types" {
  type        = list(string)
  description = "List of EC2 instance types for the node group"
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  type        = number
  description = "Desired number of nodes in the node group"
  default     = 2
}

variable "node_group_min_size" {
  type        = number
  description = "Minimum number of nodes in the node group"
  default     = 1
}

variable "node_group_max_size" {
  type        = number
  description = "Maximum number of nodes in the node group"
  default     = 4
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

