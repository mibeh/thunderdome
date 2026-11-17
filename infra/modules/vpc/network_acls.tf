resource "aws_network_acl" "vuln" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.vuln.id]

  egress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "6"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "-1"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.offense_subnet_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Thunderdome Vulnerable"
  }
}

resource "aws_network_acl" "offense" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.offense.id]

  egress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "6"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "-1"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.vuln_subnet_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "6"
    rule_no    = 140
    action     = "allow"
    cidr_block = var.vectr_subnet_cidr
    from_port  = 8081
    to_port    = 8081
  }

  ingress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "-1"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vuln_subnet_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Thunderdome Offense"
  }
}

resource "aws_network_acl" "vectr" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.vectr.id]

  egress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "6"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "6"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.offense_subnet_cidr
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "6"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.offense_subnet_cidr
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "6"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.offense_subnet_cidr
    from_port  = 8081
    to_port    = 8081
  }

  tags = {
    Name = "Thunderdome VECTR"
  }
}

resource "aws_network_acl" "nat" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.nat.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Thunderdome NAT"
  }
}

resource "aws_network_acl" "interface_endpoints" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.interface_endpoints.id]

  egress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "6"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "Thunderdome Interface Endpoints"
  }
}
