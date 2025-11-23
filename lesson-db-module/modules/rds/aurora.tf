# Aurora Cluster (when use_aurora = true)
resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.db_identifier}-cluster"

  engine         = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"
  engine_version = var.engine_version
  engine_mode    = "provisioned"

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  port            = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = var.engine == "postgres" ? aws_rds_cluster_parameter_group.aurora_postgres[0].name : aws_rds_cluster_parameter_group.aurora_mysql[0].name

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_identifier}-cluster-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? var.enabled_cloudwatch_logs_exports : (var.engine == "mysql" ? ["audit", "error", "general", "slowquery"] : [])
  deletion_protection             = var.deletion_protection
  storage_encrypted               = var.storage_encrypted

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-cluster"
  })
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? var.aurora_cluster_instances : 0

  identifier         = "${var.db_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = var.engine == "postgres" ? aws_rds_cluster.this[0].engine : aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  publicly_accessible = var.publicly_accessible

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-instance-${count.index + 1}"
  })
}

# IAM Role for Enhanced Monitoring (optional)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.use_aurora && var.monitoring_interval > 0 ? 1 : 0

  name = "${var.db_identifier}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.use_aurora && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

