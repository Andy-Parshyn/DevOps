locals {
  engine_major_version = split(".", var.engine_version)[0]

  default_ports = {
    postgres = 5432
    mysql    = 3306
  }

  db_port = var.db_port != null ? var.db_port : local.default_ports[var.engine]

  pg_family = var.parameter_group_family != "" ? var.parameter_group_family : (
    var.use_aurora
    ? "aurora-postgresql${local.engine_major_version}"
    : "${var.engine}${local.engine_major_version}"
  )

  aurora_engine = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"
}

# --- Subnet Group ---
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# --- Security Group ---
resource "aws_security_group" "this" {
  name        = "${var.identifier}-rds-sg"
  description = "Allow database traffic from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Database access from VPC"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-rds-sg"
  })
}

# --- Parameter Group (instance-level, used by both RDS and Aurora writer) ---
resource "aws_db_parameter_group" "this" {
  name   = "${var.identifier}-pg"
  family = local.pg_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-parameter-group"
  })
}

# --- Cluster Parameter Group (Aurora only) ---
resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.identifier}-cluster-pg"
  family = local.pg_family

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-cluster-parameter-group"
  })
}
