output "vuln_subnet_id" {
  value       = aws_subnet.vuln.id
  description = "The subnet-id for the vulnerable subnet"
}

output "vuln_subnet_name" {
  value       = aws_subnet.vuln
  description = "The terraform resource name for the vulnerable subnet"
}

output "offense_subnet_id" {
  value       = aws_subnet.offense.id
  description = "The subnet-id for the offense subnet"
}

output "dmz_subnet_id" {
  value       = aws_subnet.dmz.id
  description = "The subnet-id for the DMZ subnet"
}

output "endpoint_subnet_id" {
  value       = aws_subnet.interface_endpoints.id
  description = "The subnet-id for the interface endpoints subnet"
}

output "vpn_endpoint_sec_group_id" {
  value       = aws_security_group.vpn_endpoints.id
  description = "The subnet-id for the vpc endpoints subnet"
}

output "vpc_id" {
  value       = aws_vpc.thunderdome_vpc.id
  description = "The vpc-id for the VPC"
}

output "offense_security_group" {
  value       = aws_security_group.offense.id
  description = "The security group for offense instances"
}

output "dmz_security_group" {
  value       = aws_security_group.dmz.id
  description = "The security group for DMZ instances"
}

output "vpc_endpoint_security_group" {
  value       = aws_security_group.interface_endpoints.id
  description = "The security group for VPC endpoints"
}

# Outputs for root module
output "NETWORK_VPC" {
  value       = aws_vpc.thunderdome_vpc.cidr_block
  description = "The CIDR block of the VPC, used to print to terminal"
}

output "NETWORK_VULN" {
  value       = aws_subnet.vuln.cidr_block
  description = "The CIDR block for the vulnerable subnet, used to print to terminal"
}

output "NETWORK_NAT" {
  value       = aws_subnet.nat.cidr_block
  description = "The CIDR block for the NAT subnet, used to print to terminal"
}

output "NETWORK_ENDPOINTS" {
  value       = aws_subnet.interface_endpoints.cidr_block
  description = "The CIDR block for the VPC endpoints subnet, used to print to terminal"
}

output "NETWORK_offense" {
  value       = aws_subnet.offense.cidr_block
  description = "The CIDR block for the offense subnet, used to print to terminal"
}
