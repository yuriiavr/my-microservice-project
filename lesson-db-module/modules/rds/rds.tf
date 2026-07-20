# Звичайна RDS instance — створюється, коли use_aurora = false.

resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.identifier}-pg"
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
    Name = "${var.identifier}-pg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  db_name  = var.db_name
  username = var.master_username
  password = var.master_password
  port     = local.port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this[0].name

  publicly_accessible = var.publicly_accessible
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = merge(var.tags, {
    Name = var.identifier
  })
}
