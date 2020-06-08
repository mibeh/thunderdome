# Client VPN endpoint
# server_certificate_arn and root_certificate_chain_arn can be the same
resource "aws_ec2_client_vpn_endpoint" "vpn_endpoints" {
  count                  = var.vpn_enabled ? 1 : 0
  description            = "Endpoints for VPN connections"
  server_certificate_arn = data.aws_acm_certificate.vpn_certificate.arn
  client_cidr_block      = var.vpn_endpoint_cidr
  split_tunnel           = true
  transport_protocol     = "udp"
  dns_servers            = []
  tags = {
    "Name" = "Thunderdome VPN"
  }

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.vpn_certificate.arn
  }

  connection_log_options {
    enabled               = var.vpn_logging_enabled
    cloudwatch_log_group  = aws_cloudwatch_log_group.thunderdome_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.thunderdome_vpn_connections.name
  }
}

data "aws_acm_certificate" "vpn_certificate" {
  domain      = "server.thunderdome.lab"
  types       = ["IMPORTED"]
  most_recent = true
}

# VPN Endpoint network associations
resource "aws_ec2_client_vpn_network_association" "vuln" {
  count                  = var.vpn_enabled ? 1 : 0
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoints[0].id
  subnet_id              = var.vuln_subnet_id
}

# Ingress Authorization
resource "null_resource" "ingress_auth" {
  provisioner "local-exec" {
    command = "aws ec2 authorize-client-vpn-ingress --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoints[0].id} --authorize-all-groups --target-network-cidr 10.0.0.0/17"
  }
  # Need to wait until the endpoint is created
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoints[0]]
}

# Apply security group to VPN target network association
resource "null_resource" "vpn_sec_group_assoc" {
  provisioner "local-exec" {
    command = "aws ec2 apply-security-groups-to-client-vpn-target-network --security-group-ids ${var.vpn_endpoint_sec_group_id} --vpc-id ${var.vpc_id} --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoints[0].id}"
  }
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoints[0]]
}

# Download Client VPN Client Configuration File
resource "null_resource" "download_config" {
  provisioner "local-exec" {
    command = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.vpn_endpoints[0].id} --output text > ../.vpn-info/config.ovpn"
  }
  # Need to wait until the endpoint is created
  depends_on = [aws_ec2_client_vpn_endpoint.vpn_endpoints[0]]
}

resource "null_resource" "gen_vpn_config" {
  provisioner "local-exec" {
    command = "/bin/bash ${path.root}/../scripts/gen_vpn_config.sh"
  }
  depends_on = [null_resource.download_config]
}
