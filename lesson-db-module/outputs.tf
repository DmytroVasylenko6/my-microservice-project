output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint (when use_aurora = false)"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint (when use_aurora = true)"
  value       = module.rds.aurora_cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint (when use_aurora = true)"
  value       = module.rds.aurora_cluster_reader_endpoint
}

output "database_name" {
  description = "Database name"
  value       = module.rds.database_name
}

output "database_username" {
  description = "Database master username"
  value       = module.rds.database_username
  sensitive   = true
}

