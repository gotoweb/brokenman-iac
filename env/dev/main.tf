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
  security_groups = {
    ecs = module.sg.allow_http_https_id
  }
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
    secretsmanager_arn = module.secretsmanager.arn
  })

  desired_count = 2

  service_subnets = module.vpc.private_subnets
  service_security_groups = [ module.sg.allow_http_https_id ]
  alb_subnets = module.vpc.public_subnets
}

module "secretsmanager" {
  source = "../../modules/secretsmanager"
  name = "${var.name}-rds"
  secret_string = {
    RDS_USERNAME = var.database_username
    RDS_PASSWORD = var.database_password
    RDS_HOSTNAME = var.database_hostname
    RDS_DATABASE = var.database_name
  }
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