# Subnets

resource "aws_subnet" "vuln" {
  vpc_id            = aws_vpc.thunderdome_vpc.id
  cidr_block        = var.vuln_subnet_cidr
  availability_zone = var.vpc_availability_zone
  tags = {
    Name = "Thunderdome Vulnerable"
  }
}

resource "aws_subnet" "offense" {
  vpc_id            = aws_vpc.thunderdome_vpc.id
  cidr_block        = var.offense_subnet_cidr
  availability_zone = var.vpc_availability_zone
  tags = {
    Name = "Thunderdom Offense"
  }
}

resource "aws_subnet" "nat" {
  vpc_id            = aws_vpc.thunderdome_vpc.id
  cidr_block        = var.nat_subnet_cidr
  availability_zone = var.vpc_availability_zone
  tags = {
    Name = "Thunderdom NAT"
  }
}

resource "aws_subnet" "dmz" {
  vpc_id            = aws_vpc.thunderdome_vpc.id
  cidr_block        = var.dmz_subnet_cidr
  availability_zone = var.vpc_availability_zone
  tags = {
    Name = "Thunderdom DMZ"
  }
}

resource "aws_subnet" "interface_endpoints" {
  vpc_id            = aws_vpc.thunderdome_vpc.id
  cidr_block        = var.interface_endpoint_subnet_cidr
  availability_zone = var.vpc_availability_zone
  tags = {
    Name = "Thunderdom Interface Endpoints"
  }
}
