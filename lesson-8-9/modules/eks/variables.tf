variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "ID приватних підмереж для worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "ID публічних підмереж для EKS API endpoint"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Тип інстансів для worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Бажана кількість нод"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість нод"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Максимальна кількість нод"
  type        = number
  default     = 3
}