variable "vpn_endpoint_cidr" {
  type        = string
  default     = "10.0.132.0/22"
  description = "The CIDR block for the VPN endpoints"
}

variable "vuln_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/17"
  description = "The CIDR block for the Vulnerable subnet"
}

variable "vuln_subnet_id" {
  type        = string
  description = "The id of the vulnerable subnet resource"
}

variable "vuln_subnet_name" {
  type        = any
  description = "The name of the vulnerable subnet resource"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC resource"
}

variable "vpn_endpoint_sec_group_id" {
  type        = string
  description = "The id of the VPN Endpoint resource"
}

variable "offense_subnet_id" {
  type        = string
  description = "The id of the offense subnet resource"
}

variable "vpn_logging_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable logging of Client VPN connections"
}

variable "vpn_enabled" {
  type        = bool
  description = "If true, enables creates the VPC endpoints needed for SSM"
}

variable "interface_endpoints_subnet" {
  type        = string
  description = "The subnet for VPC interface endpoints"
}

variable "vpc_endpoint_sec_group" {
  type        = string
  description = "The security group for VPC interface endpoints"
}

variable "vpc_region" {
  type        = string
  description = "The region the VPC is in"
}
