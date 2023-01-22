module "vpc" {
  source = "../../modules/vpc"
  name = var.env
  ipv4_cidr = var.ipv4_cidr
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.id
}

module "vpce" {
  source = "../../modules/vpce"
  name = var.env
  vpc_id = module.vpc.id
  security_groups = [ module.sg.allow_http_https_id ]
  private_subnets = module.vpc.private_subnets
}

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  name = "/ecs/${var.env}-logs"
}

module "ecs" {
  source = "../../modules/ecs"
  name = var.env
  vpc_id = module.vpc.id
  container_port = var.container_port

  container_definitions = templatefile("container-def.json.tftpl", {
    name = var.env
    uri = var.container_uri
    port = var.container_port
    log_group = aws_cloudwatch_log_group.cluster_log_group.id
  })

  service_subnets = module.vpc.private_subnets
  service_security_groups = [ module.sg.allow_http_https_id ]
  alb_subnets = module.vpc.public_subnets
}