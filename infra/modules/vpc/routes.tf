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
    Name = "Thunderdoem NAT Route Table"
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


resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome DMZ Route Table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = aws_subnet.dmz.id
  route_table_id = aws_route_table.dmz.id
}
