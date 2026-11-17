# Route Tables & Associations

resource "aws_route_table" "vuln" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome Vulnerable Route Table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "vuln" {
  subnet_id      = aws_subnet.vuln.id
  route_table_id = aws_route_table.vuln.id
}

resource "aws_route_table" "offense" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome Offense Route Table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "offense" {
  subnet_id      = aws_subnet.offense.id
  route_table_id = aws_route_table.offense.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome NAT Route Table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.nat.id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table" "vectr" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome VECTR Route Table"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "vectr" {
  subnet_id      = aws_subnet.vectr.id
  route_table_id = aws_route_table.vectr.id
}

resource "aws_route_table" "interface_endpoints" {
  vpc_id = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome Interface Endpoints Route Table"
  }
}

resource "aws_route_table_association" "interface_endpoints" {
  subnet_id      = aws_subnet.interface_endpoints.id
  route_table_id = aws_route_table.interface_endpoints.id
}
