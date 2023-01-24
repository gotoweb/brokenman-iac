output "alb_endpoint" {
  value = module.ecs.alb_endpoint
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "azs" {
  value = slice(data.aws_availability_zones.available.names, 0, 2)
}