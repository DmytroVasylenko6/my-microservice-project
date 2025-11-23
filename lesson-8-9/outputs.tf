output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = module.jenkins.jenkins_url
  sensitive   = false
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = true
}

output "argo_cd_url" {
  description = "Argo CD URL"
  value       = module.argo_cd.argo_cd_url
  sensitive   = false
}

output "argo_cd_admin_password" {
  description = "Argo CD admin password"
  value       = module.argo_cd.argo_cd_admin_password
  sensitive   = true
}

