# Route Tables & Associations

resource "aws_route_table" "vuln" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Vuln"
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
    Name = "Offense"
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
    Name = "NAT"
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
