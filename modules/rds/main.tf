locals {
  is_serverless = var.instance_class == "db.serverless"
}

resource "aws_db_subnet_group" "subnet_group" {
  name = "${var.name}-subnet-group"
  subnet_ids = var.subnets
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier = var.name

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  engine = var.engine
  engine_mode = local.is_serverless ? "provisioned" : var.engine_mode
  engine_version = local.is_serverless ? "13.7" : var.engine_version
  database_name = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  backup_retention_period = 7
  copy_tags_to_snapshot = true
  skip_final_snapshot = true

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.is_serverless ? [var.serverlessv2_scaling_configuration] : []

    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count = 2
  identifier = "${var.name}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class = var.instance_class
  engine = aws_rds_cluster.cluster.engine
  engine_version = aws_rds_cluster.cluster.engine_version
}