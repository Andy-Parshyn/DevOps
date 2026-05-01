terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# S3 backend
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-andy-parshyn-devops-study"
  table_name  = "terraform-locks"
}

# VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "lesson-10-vpc"
  eks_cluster_name   = "lesson-10-eks"
}

# ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-10-django"
  scan_on_push = true
}

# EKS
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "lesson-10-eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 3
}

# Jenkins
module "jenkins" {
  source = "./modules/jenkins"

  jenkins_admin_password = var.jenkins_admin_password

  depends_on = [module.eks]
}

# Argo CD
module "argo_cd" {
  source       = "./modules/argo_cd"
  git_repo_url = "https://github.com/Andy-Parshyn/DevOps.git"

  depends_on = [module.eks]
}

# RDS
module "rds" {
  source = "./modules/rds"

  identifier         = "lesson-10-db"
  use_aurora         = false
  engine             = "postgres"
  engine_version     = "15.4"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  multi_az           = false
  db_name            = "appdb"
  db_username        = "dbadmin"
  db_password        = var.db_password
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_cidr_block     = "10.0.0.0/16"

  depends_on = [module.vpc]
}

# Monitoring (Prometheus + Grafana via kube-prometheus-stack)
module "monitoring" {
  source = "./modules/monitoring"

  grafana_admin_password = var.grafana_admin_password

  depends_on = [module.eks]
}