resource "aws_security_group" "vulnerable" {
  name_prefix = "thunderdome-vulnerable-"
  description = "Traffic for deliberately vulnerable range instances"
  vpc_id      = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome Vulnerable"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vulnerable_from_offense" {
  security_group_id            = aws_security_group.vulnerable.id
  referenced_security_group_id = aws_security_group.offense.id
  ip_protocol                  = "-1"
  description                  = "Attack traffic from offensive instances"
}

resource "aws_vpc_security_group_ingress_rule" "vulnerable_from_vpn" {
  for_each = {
    http  = 80
    https = 443
    rdp   = 3389
    ssh   = 22
  }

  security_group_id            = aws_security_group.vulnerable.id
  referenced_security_group_id = aws_security_group.vpn_endpoints.id
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
  description                  = "${upper(each.key)} from Client VPN"
}

resource "aws_vpc_security_group_egress_rule" "vulnerable_callback" {
  for_each = toset(["tcp", "udp"])

  security_group_id            = aws_security_group.vulnerable.id
  referenced_security_group_id = aws_security_group.offense.id
  from_port                    = 1024
  to_port                      = 65535
  ip_protocol                  = each.value
  description                  = "${upper(each.value)} callbacks to offensive instances"
}

resource "aws_vpc_security_group_egress_rule" "vulnerable_web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.vulnerable.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  ip_protocol       = "tcp"
  description       = "Package and Systems Manager traffic"
}

resource "aws_vpc_security_group_egress_rule" "vulnerable_dns_udp" {
  security_group_id = aws_security_group.vulnerable.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  description       = "VPC DNS"
}

resource "aws_vpc_security_group_egress_rule" "vulnerable_dns_tcp" {
  security_group_id = aws_security_group.vulnerable.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  description       = "VPC DNS fallback"
}

resource "aws_security_group" "offense" {
  name_prefix = "thunderdome-offense-"
  description = "Traffic for private offensive instances"
  vpc_id      = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome Offense"
  }
}

resource "aws_vpc_security_group_ingress_rule" "offense_ssh_from_vpn" {
  security_group_id            = aws_security_group.offense.id
  referenced_security_group_id = aws_security_group.vpn_endpoints.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "SSH from Client VPN"
}

resource "aws_vpc_security_group_ingress_rule" "offense_callback" {
  for_each = toset(["tcp", "udp"])

  security_group_id            = aws_security_group.offense.id
  referenced_security_group_id = aws_security_group.vulnerable.id
  from_port                    = 1024
  to_port                      = 65535
  ip_protocol                  = each.value
  description                  = "${upper(each.value)} callbacks from vulnerable instances"
}

resource "aws_vpc_security_group_egress_rule" "offense_to_vulnerable" {
  security_group_id = aws_security_group.offense.id
  cidr_ipv4         = var.vuln_subnet_cidr
  ip_protocol       = "-1"
  description       = "Attack traffic to vulnerable subnet"
}

resource "aws_vpc_security_group_egress_rule" "offense_web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.offense.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  ip_protocol       = "tcp"
  description       = "Package and Systems Manager traffic"
}

resource "aws_vpc_security_group_egress_rule" "offense_dns_udp" {
  security_group_id = aws_security_group.offense.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  description       = "VPC DNS"
}

resource "aws_vpc_security_group_egress_rule" "offense_dns_tcp" {
  security_group_id = aws_security_group.offense.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  description       = "VPC DNS fallback"
}

resource "aws_security_group" "vectr" {
  name_prefix = "thunderdome-vectr-"
  description = "Private VECTR access through Client VPN"
  vpc_id      = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome VECTR"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vectr_from_vpn" {
  for_each = toset(["443", "8081"])

  security_group_id            = aws_security_group.vectr.id
  referenced_security_group_id = aws_security_group.vpn_endpoints.id
  from_port                    = tonumber(each.key)
  to_port                      = tonumber(each.key)
  ip_protocol                  = "tcp"
  description                  = "VECTR access from Client VPN"
}

resource "aws_vpc_security_group_egress_rule" "vectr_web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.vectr.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  ip_protocol       = "tcp"
  description       = "VECTR updates and Systems Manager traffic"
}

resource "aws_vpc_security_group_egress_rule" "vectr_dns_udp" {
  security_group_id = aws_security_group.vectr.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  description       = "VPC DNS"
}

resource "aws_vpc_security_group_egress_rule" "vectr_dns_tcp" {
  security_group_id = aws_security_group.vectr.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  description       = "VPC DNS fallback"
}

resource "aws_security_group" "vpn_endpoints" {
  name_prefix = "thunderdome-client-vpn-"
  description = "Client VPN traffic into the private range"
  vpc_id      = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome Client VPN"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpn_to_vpc" {
  security_group_id = aws_security_group.vpn_endpoints.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
  description       = "Authorized Client VPN traffic to the VPC"
}

resource "aws_security_group" "interface_endpoints" {
  name_prefix = "thunderdome-interface-endpoints-"
  description = "Private interface endpoints"
  vpc_id      = aws_vpc.thunderdome_vpc.id

  tags = {
    Name = "Thunderdome Interface Endpoints"
  }
}

resource "aws_vpc_security_group_ingress_rule" "interface_endpoints_https" {
  security_group_id = aws_security_group.interface_endpoints.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS from private range hosts"
}
