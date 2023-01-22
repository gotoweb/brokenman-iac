resource "aws_vpc" "vpc" {
  cidr_block = var.ipv4_cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.name}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.ipv4_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.ipv4_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "${var.name}-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.name}-igw"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.name}-private-rtb"
  }
}

resource "aws_route_table_association" "private_rtb_association" {
  count = 2
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.name}-public-rtb"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-2.s3"
  tags = {
    "Name" = "${var.name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "public_rtb_endpoint" {
  route_table_id = aws_route_table.private_rtb.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}