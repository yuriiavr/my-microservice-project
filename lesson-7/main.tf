terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Підключаємо модуль S3 та DynamoDB (бекенд для стейтів).
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.state_bucket_name
  table_name  = var.dynamodb_table_name
}

# Підключаємо модуль VPC (та сама мережа, що й у попередніх темах).
# cluster_name потрібен, щоб підмережі отримали тег kubernetes.io/cluster/<name>.
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  vpc_name           = "lesson-7-vpc"
  cluster_name       = var.cluster_name
}

# Підключаємо модуль ECR (репозиторій для Django-образу).
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

# Підключаємо модуль EKS (кластер Kubernetes у створеній VPC).
module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Control plane — у всіх підмережах; ноди — лише в приватних.
  subnet_ids      = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}
