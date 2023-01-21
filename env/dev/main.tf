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
  security_group_ids = [ module.sg.allow_http_https_id ]
  private_subnet_ids = module.vpc.private_subnets_id
}