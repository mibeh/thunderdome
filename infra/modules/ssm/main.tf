locals {
  ssm_endpoint_services = toset([
    "ec2messages",
    "ssm",
    "ssmmessages",
  ])
}

resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = var.enable_ssm_endpoints ? local.ssm_endpoint_services : toset([])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.vpc_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.interface_endpoints_subnet]
  security_group_ids  = [var.vpc_endpoint_sec_group]

  tags = {
    Name = "Thunderdome ${each.key} endpoint"
  }
}
