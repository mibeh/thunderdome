# Subnets

resource "aws_subnet" "vuln" {
  vpc_id                  = aws_vpc.thunderdome_vpc.id
  cidr_block              = var.vuln_subnet_cidr
  availability_zone       = var.vpc_availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "Thunderdome Vulnerable"
  }
}

resource "aws_subnet" "offense" {
  vpc_id                  = aws_vpc.thunderdome_vpc.id
  cidr_block              = var.offense_subnet_cidr
  availability_zone       = var.vpc_availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "Thunderdome Offense"
  }
}

resource "aws_subnet" "nat" {
  vpc_id                  = aws_vpc.thunderdome_vpc.id
  cidr_block              = var.nat_subnet_cidr
  availability_zone       = var.vpc_availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "Thunderdome NAT"
  }
}

resource "aws_subnet" "vectr" {
  vpc_id                  = aws_vpc.thunderdome_vpc.id
  cidr_block              = var.vectr_subnet_cidr
  availability_zone       = var.vpc_availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "Thunderdome VECTR"
  }
}

resource "aws_subnet" "interface_endpoints" {
  vpc_id                  = aws_vpc.thunderdome_vpc.id
  cidr_block              = var.interface_endpoint_subnet_cidr
  availability_zone       = var.vpc_availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "Thunderdome Interface Endpoints"
  }
}
