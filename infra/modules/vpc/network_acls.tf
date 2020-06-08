# Network ACLs

resource "aws_network_acl" "vuln" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.vuln.id]
  tags = {
    Name = "Thunderdome Vulnerable"
  }
  egress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 443
    },
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 80
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 2
      to_port         = 80
    },
    {
      action          = "allow"
      cidr_block      = var.offense_subnet_cidr
      from_port       = 0
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "-1"
      rule_no         = 3
      to_port         = 0
    },
  ]

  ingress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 4
      to_port         = 65535
    },
    {
      action          = "allow"
      cidr_block      = var.offense_subnet_cidr
      from_port       = 0
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "-1"
      rule_no         = 5
      to_port         = 0
    },
    {
      action          = "allow"
      cidr_block      = var.vpn_cidr
      from_port       = 22
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 6
      to_port         = 22
    },
    {
      action          = "allow"
      cidr_block      = var.vpn_cidr
      from_port       = 3389
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 7
      to_port         = 3389
    },
    {
      action          = "allow"
      cidr_block      = var.vpn_cidr
      from_port       = 80
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 8
      to_port         = 80
    },
    {
      action          = "allow"
      cidr_block      = var.vpn_cidr
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 9
      to_port         = 443
    }
  ]
}

resource "aws_network_acl" "offense" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.offense.id]
  tags = {
    Name = "Thunderdome Offense"
  }

  egress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 443
    },
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 80
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 2
      to_port         = 80
    },
    {
      action          = "allow"
      cidr_block      = var.vuln_subnet_cidr
      from_port       = 0
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "-1"
      rule_no         = 3
      to_port         = 0
    },
  ]

  ingress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 65535
    },
    {
      action          = "allow"
      cidr_block      = var.vuln_subnet_cidr
      from_port       = 0
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "-1"
      rule_no         = 2
      to_port         = 0
    },
  ]
}

resource "aws_network_acl" "nat" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.nat.id]
  tags = {
    Name = "Thunderdome NAT"
  }

  egress = [
    {
      action          = "allow"
      cidr_block      = var.vpc_cidr
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 65535
    },
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 2
      to_port         = 443
    },
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 80
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 3
      to_port         = 80
    },
  ]

  ingress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 3
      to_port         = 65535
    },
    {
      action          = "allow"
      cidr_block      = var.vpc_cidr
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 2
      to_port         = 443
    },
    {
      action          = "allow"
      cidr_block      = var.vpc_cidr
      from_port       = 80
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 80
    },
  ]
}

resource "aws_network_acl" "interface_endpoints" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.interface_endpoints.id]
  tags = {
    Name = "Thunderdome Interface Endpoints"
  }

  egress = [
    {
      action          = "allow"
      cidr_block      = var.vpc_cidr
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 65535
    },
  ]

  ingress = [
    {
      action          = "allow"
      cidr_block      = var.vpc_cidr
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 443
    },
  ]
}

resource "aws_network_acl" "dmz" {
  vpc_id     = aws_vpc.thunderdome_vpc.id
  subnet_ids = [aws_subnet.dmz.id]
  tags = {
    Name = "Thunderdome DMZ"
  }

  egress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 1024
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 3
      to_port         = 65535
    },

  ]

  ingress = [
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 443
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 1
      to_port         = 443
    },
    {
      action          = "allow"
      cidr_block      = "0.0.0.0/0"
      from_port       = 8081
      icmp_code       = 0
      icmp_type       = 0
      ipv6_cidr_block = ""
      protocol        = "6"
      rule_no         = 3
      to_port         = 8081
    },
  ]
}
