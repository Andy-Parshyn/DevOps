locals {
  engine_major_version = split(".", var.engine_version)[0]

  pg_family = var.parameter_group_family != "" ? var.parameter_group_family : (
    var.use_aurora
    ? "aurora-postgresql${local.engine_major_version}"
    : "${var.engine}${local.engine_major_version}"
  )
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
    from_port   = 5432
    to_port     = 5432
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

# --- Parameter Group ---
resource "aws_db_parameter_group" "this" {
  name   = "${var.identifier}-pg"
  family = local.pg_family

  parameter {
    name  = "max_connections"
    value = "100"
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
