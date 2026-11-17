variable "vpn_enabled" {
  type        = bool
  description = "Create the AWS Client VPN endpoint when true"
}

variable "vpn_logging_enabled" {
  type        = bool
  default     = true
  description = "Send Client VPN connection logs to CloudWatch Logs"
}

variable "vpn_endpoint_cidr" {
  type        = string
  description = "CIDR allocated to Client VPN clients"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR authorized for Client VPN access"
}

variable "vpc_dns_server" {
  type        = string
  description = "VPC Route 53 Resolver address advertised to VPN clients"
}

variable "vpc_id" {
  type        = string
  description = "VPC that owns the Client VPN target network"
}

variable "association_subnet_id" {
  type        = string
  description = "Private subnet associated with the Client VPN endpoint"
}

variable "vpn_security_group_id" {
  type        = string
  description = "Security group assigned natively to the Client VPN endpoint"
}

variable "server_certificate_domain" {
  type        = string
  default     = "server.thunderdome.lab"
  description = "Domain on the imported ACM server certificate"
}

variable "name_prefix" {
  type        = string
  default     = "thunderdome"
  description = "Prefix used for Client VPN resource names"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to Client VPN resources"
}
