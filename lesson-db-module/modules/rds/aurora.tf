# Aurora Cluster — створюється, коли use_aurora = true.

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.identifier}-cluster-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "${var.identifier}-cluster-pg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = var.identifier
  engine             = var.engine
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.master_username
  master_password = var.master_password
  port            = local.port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.identifier
  })
}

# Інстанси кластера: перший — writer, решта — readers.
resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier           = "${var.identifier}-${count.index}"
  cluster_identifier   = aws_rds_cluster.this[0].id
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.this.name

  publicly_accessible = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.identifier}-${count.index}"
  })
}
