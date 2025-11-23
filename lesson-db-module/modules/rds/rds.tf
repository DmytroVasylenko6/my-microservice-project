# Regular RDS Instance (when use_aurora = false)
resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = var.db_identifier

  engine         = var.engine == "postgres" ? "postgres" : "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted    = var.storage_encrypted

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  parameter_group_name    = var.engine == "postgres" ? aws_db_parameter_group.postgres[0].name : aws_db_parameter_group.mysql[0].name
  publicly_accessible     = var.publicly_accessible
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? var.enabled_cloudwatch_logs_exports : (var.engine == "mysql" ? ["audit", "error", "general", "slowquery"] : [])
  deletion_protection             = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.db_identifier
  })
}

