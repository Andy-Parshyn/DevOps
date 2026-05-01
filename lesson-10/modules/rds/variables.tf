variable "identifier" {
  description = "Identifier for the RDS instance or Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "true = Aurora Cluster + writer instance, false = single RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Supported engines: postgres, mysql."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class for RDS or Aurora writer (Aurora minimum: db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB (only for standalone RDS, ignored for Aurora)"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ for standalone RDS (Aurora is multi-AZ by default)"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for security group ingress"
  type        = string
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g. postgres15, aurora-postgresql15). Auto-derived if empty."
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port (default: 5432 for postgres, 3306 for mysql)"
  type        = number
  default     = null
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
