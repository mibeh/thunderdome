# Main VPC and attachments

resource "aws_vpc" "thunderdome_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Thunderdome VPC"
  }
}

# Elastic IP for NAT, NAT gateways, Internet Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Thunderdome NAT"
  }
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.nat.id
  allocation_id = aws_eip.nat_eip.id
  tags = {
    Name = "Thunderdome NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome Internet Gateway"
  }
}
