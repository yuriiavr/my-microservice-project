terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Провайдери kubernetes/helm автентифікуються в EKS токеном, який видає AWS.
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# --- Бекенд для стейтів (S3 + DynamoDB) --------------------------------------
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.state_bucket_name
  table_name  = var.dynamodb_table_name
}

# --- Мережа (та сама VPC, що й у попередніх темах) ---------------------------
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  vpc_name           = "lesson-8-9-vpc"
  cluster_name       = var.cluster_name
}

# --- ECR (репозиторій для Django-образу) -------------------------------------
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

# --- EKS (кластер + OIDC + EBS CSI driver) -----------------------------------
module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnet_ids      = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_subnet_ids = module.vpc.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

# --- Jenkins (Helm) з агентом Kaniko і правом push у ECR ---------------------
module "jenkins" {
  source = "./modules/jenkins"

  namespace      = var.jenkins_namespace
  chart_version  = var.jenkins_chart_version
  admin_user     = var.jenkins_admin_user
  admin_password = var.jenkins_admin_password

  cluster_name       = module.eks.cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  ecr_repository_arn = module.ecr.repository_arn

  depends_on = [module.eks]
}

# --- Argo CD (Helm) + Application, що стежить за Git --------------------------
module "argo_cd" {
  source = "./modules/argo_cd"

  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version

  git_repo_url        = var.git_repo_url
  git_target_revision = var.git_target_revision
  app_chart_path      = var.app_chart_path
  app_namespace       = var.app_namespace

  depends_on = [module.eks]
}
