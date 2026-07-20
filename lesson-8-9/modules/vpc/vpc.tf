# Теги для інтеграції підмереж з EKS та балансувальниками навантаження.
# Публічні підмережі отримують role/elb — там EKS створює зовнішні LoadBalancer-и.
# Приватні — role/internal-elb для внутрішніх балансувальників.
locals {
  cluster_tags = var.cluster_name != "" ? {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  } : {}
}

# --- VPC ----------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# --- Internet Gateway (для публічних підмереж) --------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# --- Публічні підмережі (3 шт.) -----------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                     = "${var.vpc_name}-public-${count.index + 1}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    },
    local.cluster_tags
  )
}

# --- Приватні підмережі (3 шт.) -----------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name                              = "${var.vpc_name}-private-${count.index + 1}"
      Tier                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    },
    local.cluster_tags
  )
}

# --- NAT Gateway (для вихідного трафіку приватних підмереж) -------------------
# Elastic IP для NAT Gateway.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateway розміщується в першій публічній підмережі.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}
