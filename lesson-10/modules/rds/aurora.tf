resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = var.identifier
  engine             = local.aurora_engine
  engine_version     = var.engine_version
  port               = local.db_port

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  storage_encrypted   = true
  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(var.tags, {
    Name = "${var.identifier}-cluster"
  })
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.identifier}-writer"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  db_parameter_group_name = aws_db_parameter_group.this.name

  tags = merge(var.tags, {
    Name = "${var.identifier}-writer"
  })
}
