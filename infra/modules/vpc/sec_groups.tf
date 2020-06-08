# Security Groups
resource "aws_security_group" "vulnerable" {
  description = "Security group for vulnerable instances"
  vpc_id      = aws_vpc.thunderdome_vpc.id
  tags = {
    Name = "Thunderdome Vulnerable"
  }
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTPS"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        var.offense_subnet_cidr,
      ]
      description      = "Offense TCP"
      from_port        = 1024
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 65535
    },
    {
      cidr_blocks = [
        var.offense_subnet_cidr,
      ]
      description      = "Offense UDP"
      from_port        = 1024
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "udp"
      security_groups  = []
      self             = false
      to_port          = 65535
    },
  ]

  ingress = [
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "RDP from VPN"
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
    {
      cidr_blocks = [
        var.offense_subnet_cidr,
      ]
      description      = "Offense Traffic"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "SSH from VPN"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "HTTP from VPN"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "RDP from VPN"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
}



resource "aws_security_group" "offense" {
  tags = {
    Name = "Thunderdome Offense"
  }
  description = "Security group for offensive instances"
  vpc_id      = aws_vpc.thunderdome_vpc.id

}

resource "aws_security_group_rule" "offense_3" {
  description       = "offense TCP"
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.offense.id
  cidr_blocks       = ["10.0.0.0/17"]
}

resource "aws_security_group_rule" "offense_4" {
  description       = "offense UDP"
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "udp"
  security_group_id = aws_security_group.offense.id
  cidr_blocks       = ["10.0.0.0/17"]
}

resource "aws_security_group_rule" "offense_5" {
  description       = "HTTP"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.offense.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "offense_6" {
  description       = "HTTPS"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.offense.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "offense_7" {
  description       = "offense Traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.offense.id
  cidr_blocks       = ["10.0.0.0/17"]
}

resource "aws_security_group" "vpn_endpoints" {
  tags = {
    Name = "VPN Endpoints"
  }
  description = "Security group for VPN endpoints"
  vpc_id      = aws_vpc.thunderdome_vpc.id
  egress = [
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "RDP to Vuln"
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
    {
      cidr_blocks = [
        var.vuln_subnet_cidr,
      ]
      description      = "SSH to Vuln"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
  ]
}

resource "aws_security_group" "interface_endpoints" {
  tags = {
    Name = "Thunderdome Interface Endpoints"
  }
  description = "Security group for Interface Endpoints"
  vpc_id      = aws_vpc.thunderdome_vpc.id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTPS for Interface Endpoints"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        var.vpc_cidr,
      ]
      description      = "HTTPS for Interface Endpoints"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
  ]
}

resource "aws_security_group" "dmz" {
  tags = {
    Name = "Thunderdome DMZ"
  }
  description = "Security gropud for DMZ"
  vpc_id      = aws_vpc.thunderdome_vpc.id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTPS DMZ"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTP DMZ"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Needed for VECTR updates"
      from_port        = 81
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 81
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "HTTPS from Internet"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "VECTR from Internet"
      from_port        = 8081
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8081
    },
  ]
}