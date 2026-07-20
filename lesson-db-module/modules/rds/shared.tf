# Спільні ресурси та обчислення для обох типів БД (RDS instance та Aurora).

locals {
  is_postgres = length(regexall("postgres", var.engine)) > 0
  port        = var.port != null ? var.port : (local.is_postgres ? 5432 : 3306)
}

# --- DB Subnet Group ---------------------------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# --- Security Group ----------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Access to ${var.identifier} database"
  vpc_id      = var.vpc_id

  # Доступ із дозволених CIDR-блоків.
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "DB from allowed CIDRs"
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Доступ від дозволених Security Group (напр. ноди EKS).
  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "DB from allowed security groups"
      from_port       = local.port
      to_port         = local.port
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-sg"
  })
}
