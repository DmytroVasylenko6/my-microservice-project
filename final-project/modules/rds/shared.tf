# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-subnet-group"
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for ${var.db_identifier} database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow database access from specified CIDR blocks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-sg"
  })
}

# Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "postgres" {
  count = var.engine == "postgres" ? 1 : 0

  family = "postgres${replace(var.engine_version, "/\\.[0-9]+$/", "")}"
  name   = "${var.db_identifier}-postgres-params"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.work_mem
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-postgres-params"
  })
}

# Parameter Group for MySQL
resource "aws_db_parameter_group" "mysql" {
  count = var.engine == "mysql" ? 1 : 0

  family = "mysql${replace(var.engine_version, "/\\.[0-9]+$/", "")}"
  name   = "${var.db_identifier}-mysql-params"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "general_log"
    value = var.general_log
  }

  parameter {
    name  = "slow_query_log"
    value = var.slow_query_log
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-mysql-params"
  })
}

# Cluster Parameter Group for Aurora PostgreSQL
resource "aws_rds_cluster_parameter_group" "aurora_postgres" {
  count = var.use_aurora && var.engine == "postgres" ? 1 : 0

  family = "aurora-postgresql${replace(var.engine_version, "/\\.[0-9]+$/", "")}"
  name   = "${var.db_identifier}-aurora-postgres-params"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.work_mem
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-aurora-postgres-params"
  })
}

# Cluster Parameter Group for Aurora MySQL
resource "aws_rds_cluster_parameter_group" "aurora_mysql" {
  count = var.use_aurora && var.engine == "mysql" ? 1 : 0

  family = "aurora-mysql${replace(var.engine_version, "/\\.[0-9]+$/", "")}"
  name   = "${var.db_identifier}-aurora-mysql-params"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "general_log"
    value = var.general_log
  }

  parameter {
    name  = "slow_query_log"
    value = var.slow_query_log
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-aurora-mysql-params"
  })
}

