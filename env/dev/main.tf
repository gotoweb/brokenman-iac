module "vpc" {
  source = "../../modules/vpc"
  name = var.name
  ipv4_cidr = var.ipv4_cidr
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.id
}

module "vpce" {
  source = "../../modules/vpce"
  name = var.name
  vpc_id = module.vpc.id
  security_groups = [ module.sg.allow_http_https_id ]
  private_subnets = module.vpc.private_subnets
}

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  name = "/ecs/${var.name}-logs"
}

module "ecs" {
  source = "../../modules/ecs"
  name = var.name
  vpc_id = module.vpc.id
  container_port = var.container_port

  container_definitions = templatefile("container-def.json.tftpl", {
    name = var.name
    uri = var.container_uri
    port = var.container_port
    log_group = aws_cloudwatch_log_group.cluster_log_group.id
  })

  service_subnets = module.vpc.private_subnets
  service_security_groups = [ module.sg.allow_http_https_id ]
  alb_subnets = module.vpc.public_subnets
}

module "rds" {
  source = "../../modules/rds"

  name = "${var.name}-postgresql-serverlessv2"
  vpc = module.vpc.id
  subnets = module.vpc.private_subnets

  instance_class = "db.serverless"
  engine = "aurora-postgresql"

  database_name = var.database_name
  master_username = var.database_username
  master_password = var.database_password

  serverlessv2_scaling_configuration = {
    max_capacity = 32
    min_capacity = 0.5
  }
}