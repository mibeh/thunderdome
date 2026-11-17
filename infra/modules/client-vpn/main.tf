data "aws_acm_certificate" "vpn_certificate" {
  count = var.vpn_enabled ? 1 : 0

  domain      = var.server_certificate_domain
  statuses    = ["ISSUED"]
  types       = ["IMPORTED"]
  most_recent = true
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  count = var.vpn_enabled ? 1 : 0

  description            = "Thunderdome Client VPN"
  server_certificate_arn = data.aws_acm_certificate.vpn_certificate[0].arn
  client_cidr_block      = var.vpn_endpoint_cidr
  vpc_id                 = var.vpc_id
  security_group_ids     = [var.vpn_security_group_id]
  dns_servers            = [var.vpc_dns_server]
  split_tunnel           = true
  transport_protocol     = "udp"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.vpn_certificate[0].arn
  }

  connection_log_options {
    enabled               = var.vpn_logging_enabled
    cloudwatch_log_group  = var.vpn_logging_enabled ? aws_cloudwatch_log_group.client_vpn[0].name : null
    cloudwatch_log_stream = var.vpn_logging_enabled ? aws_cloudwatch_log_stream.client_vpn[0].name : null
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-client-vpn"
  })
}

resource "aws_ec2_client_vpn_network_association" "this" {
  count = var.vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this[0].id
  subnet_id              = var.association_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  count = var.vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this[0].id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
  description            = "Authorize certificate-authenticated clients to the Thunderdome VPC"

  depends_on = [aws_ec2_client_vpn_network_association.this]
}
