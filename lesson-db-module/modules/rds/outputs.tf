# RDS Instance Outputs (when use_aurora = false)
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = var.use_aurora ? null : try(aws_db_instance.this[0].endpoint, null)
}

output "rds_port" {
  description = "RDS instance port"
  value       = var.use_aurora ? null : try(aws_db_instance.this[0].port, null)
}

output "rds_address" {
  description = "RDS instance address"
  value       = var.use_aurora ? null : try(aws_db_instance.this[0].address, null)
}

output "rds_id" {
  description = "RDS instance ID"
  value       = var.use_aurora ? null : try(aws_db_instance.this[0].id, null)
}

# Aurora Cluster Outputs (when use_aurora = true)
output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = var.use_aurora ? try(aws_rds_cluster.this[0].endpoint, null) : null
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = var.use_aurora ? try(aws_rds_cluster.this[0].reader_endpoint, null) : null
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID"
  value       = var.use_aurora ? try(aws_rds_cluster.this[0].cluster_identifier, null) : null
}

output "aurora_instance_endpoints" {
  description = "List of Aurora instance endpoints"
  value       = var.use_aurora ? [for instance in aws_rds_cluster_instance.this : instance.endpoint] : []
}

# Common Outputs
output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "database_username" {
  description = "Database master username"
  value       = var.db_username
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = var.db_port
}

output "security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.rds.id
}

output "subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.this.id
}

output "parameter_group_name" {
  description = "Parameter group name (for regular RDS)"
  value       = var.use_aurora ? null : (var.engine == "postgres" ? try(aws_db_parameter_group.postgres[0].name, null) : try(aws_db_parameter_group.mysql[0].name, null))
}

output "cluster_parameter_group_name" {
  description = "Cluster parameter group name (for Aurora)"
  value       = var.use_aurora ? (var.engine == "postgres" ? try(aws_rds_cluster_parameter_group.aurora_postgres[0].name, null) : try(aws_rds_cluster_parameter_group.aurora_mysql[0].name, null)) : null
}

