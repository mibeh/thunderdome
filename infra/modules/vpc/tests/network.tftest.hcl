mock_provider "aws" {}

run "private_segmented_network" {
  command = plan

  assert {
    condition     = aws_vpc.thunderdome_vpc.enable_dns_support && aws_vpc.thunderdome_vpc.enable_dns_hostnames
    error_message = "Private DNS and hostnames must be enabled for SSM and thunderdome.lab."
  }

  assert {
    condition = (
      !aws_subnet.vuln.map_public_ip_on_launch
      && !aws_subnet.offense.map_public_ip_on_launch
      && !aws_subnet.vectr.map_public_ip_on_launch
      && !aws_subnet.interface_endpoints.map_public_ip_on_launch
      && aws_subnet.nat.map_public_ip_on_launch
    )
    error_message = "Only the NAT subnet may auto-assign public IP addresses."
  }

  assert {
    condition     = alltrue([for route in aws_route_table.vectr.route : route.gateway_id == null])
    error_message = "The private VECTR subnet must not have a direct Internet Gateway route."
  }

  assert {
    condition = length(aws_vpc_security_group_ingress_rule.vectr_from_vpn) == 2 && alltrue([
      for rule in aws_vpc_security_group_ingress_rule.vectr_from_vpn :
      rule.cidr_ipv4 == null
    ])
    error_message = "VECTR access must be limited to its two Client VPN application ports."
  }

  assert {
    condition = anytrue([
      for rule in aws_network_acl.vectr.egress :
      rule.cidr_block == var.offense_subnet_cidr && rule.from_port == 1024 && rule.to_port == 65535
    ])
    error_message = "The VECTR ACL must return translated VPN traffic to the offense subnet."
  }

  assert {
    condition = (
      length(aws_vpc_security_group_egress_rule.vulnerable_callback) == 2
      && length(aws_vpc_security_group_ingress_rule.offense_callback) == 2
    )
    error_message = "Vulnerable hosts must be able to initiate TCP and UDP callbacks to Kali high ports."
  }

  assert {
    condition     = aws_eip.nat_eip.domain == "vpc"
    error_message = "The NAT Elastic IP must use the provider-6 VPC domain argument."
  }
}
