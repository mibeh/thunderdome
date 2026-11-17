output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "Thunderdome VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.NETWORK_VPC
  description = "Thunderdome VPC CIDR"
}

output "vulnerable_subnet_cidr" {
  value       = module.vpc.NETWORK_VULN
  description = "Vulnerable target subnet CIDR"
}

output "offense_subnet_cidr" {
  value       = module.vpc.NETWORK_offense
  description = "Offensive host subnet CIDR"
}

output "vectr_subnet_cidr" {
  value       = module.vpc.NETWORK_VECTR
  description = "Private VECTR subnet CIDR"
}

output "nat_subnet_cidr" {
  value       = module.vpc.NETWORK_NAT
  description = "Public NAT gateway subnet CIDR"
}

output "endpoint_subnet_cidr" {
  value       = module.vpc.NETWORK_ENDPOINTS
  description = "Interface endpoint subnet CIDR"
}

output "client_vpn_endpoint_id" {
  value       = module.client_vpn.client_vpn_endpoint_id
  description = "Client VPN endpoint ID, or null when VPN is disabled"
}

output "vectr_url" {
  value       = module.vectr.url
  description = "Private VECTR URL, or null when VECTR is disabled"
}

output "vectr_private_ip" {
  value       = module.vectr.private_ip
  description = "Private VECTR IP address, or null when VECTR is disabled"
}

output "kali_instance_ids" {
  value       = module.kali.instance_ids
  description = "Private Kali instance IDs"
}

output "kali_ssm_session_commands" {
  value       = module.kali.ssm_session_commands
  description = "Commands that start Systems Manager sessions to Kali instances"
}
