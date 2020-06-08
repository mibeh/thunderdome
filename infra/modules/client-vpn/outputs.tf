output "vpn_endpoint_cidr" {
  value       = aws_ec2_client_vpn_endpoint.vpn_endpoints[0].client_cidr_block
  description = "The CIDR block for the VPN endpoints, needed for VPC module"
}
