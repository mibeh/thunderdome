# Various resource values to print out

output "NETWORK_VPC" {
  value       = module.vpc.NETWORK_VPC
  description = "The CIDR block of the VPC"
}

output "VPC_ID" {
  value       = module.vpc.vpc_id
  description = "The vpc-id"
}

output "NETWORK_VULN" {
  value       = module.vpc.NETWORK_VULN
  description = "The CIDR block for the vulnerable subnet"
}

output "NETWORK_offense" {
  value       = module.vpc.NETWORK_offense
  description = "The CIDR block for the offense subnet"
}

output "NETWORK_NAT" {
  value       = module.vpc.NETWORK_NAT
  description = "The CIDR block for the NAT subnet"
}

output "NETWORK_ENDPOINTS" {
  value       = module.vpc.NETWORK_ENDPOINTS
  description = "The CIDR block for the VPC endpoints subnet"
}

output "VECTR_HOST" {
  value = module.vectr.public_ip
  description = "Command to add VECTR to hosts file"
}