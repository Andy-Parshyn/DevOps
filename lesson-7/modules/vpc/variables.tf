variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDR блоки для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR блоки для приватних підмереж"
  type        = list(string)
}

variable "availability_zones" {
  description = "Список Availability Zones"
  type        = list(string)
}

variable "vpc_name" {
  description = "Назва VPC"
  type        = string
}

variable "eks_cluster_name" {
  description = "Назва EKS кластера для тегування підмереж"
  type = string
  default = ""
}