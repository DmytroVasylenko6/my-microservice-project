output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "rds_endpoint" {
  description = "RDS instance endpoint (when use_aurora = false)"
  value       = module.rds.rds_endpoint
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint (when use_aurora = true)"
  value       = module.rds.aurora_cluster_endpoint
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

output "grafana_url" {
  description = "Grafana URL (use port-forward: kubectl port-forward svc/grafana 3000:80 -n monitoring)"
  value       = "http://localhost:3000"
}

output "prometheus_url" {
  description = "Prometheus URL (use port-forward: kubectl port-forward svc/prometheus-server 9090:80 -n monitoring)"
  value       = "http://localhost:9090"
}

