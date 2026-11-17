output "client_vpn_endpoint_id" {
  value       = try(aws_ec2_client_vpn_endpoint.this[0].id, null)
  description = "Client VPN endpoint ID, or null when VPN is disabled"
}

output "vpn_endpoint_cidr" {
  value       = var.vpn_endpoint_cidr
  description = "CIDR allocated to Client VPN clients"
}
