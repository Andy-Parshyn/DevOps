output "endpoint" {
  description = "Database connection endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : aws_db_instance.this[0].port
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "db_username" {
  description = "Master username"
  value       = var.db_username
}

output "security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.this.id
}

output "reader_endpoint" {
  description = "Aurora reader endpoint (empty string if not Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : ""
}
