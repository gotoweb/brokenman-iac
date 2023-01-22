resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_groups
  subnet_ids = var.private_subnets # [ for i in aws_subnet.private_subnet : i.id ]
  private_dns_enabled = true

  tags = {
    "Name" = "${var.name}-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_groups
  subnet_ids = var.private_subnets
  private_dns_enabled = true

  tags = {
    "Name" = "${var.name}-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-2.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_groups
  subnet_ids = var.private_subnets
  private_dns_enabled = true

  tags = {
    "Name" = "${var.name}-vpce-logs"
  }
}