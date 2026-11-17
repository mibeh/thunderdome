variable "expected_aws_account_id" {
  type        = string
  description = "Twelve-digit AWS account ID allowed to receive this deployment"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_aws_account_id))
    error_message = "expected_aws_account_id must be a twelve-digit AWS account ID."
  }
}

variable "vpc_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for the deployment"
}

variable "vpc_availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "Availability Zone for single-AZ range resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for the Thunderdome VPC"
}

variable "vuln_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/17"
  description = "CIDR for vulnerable targets"
}

variable "offense_subnet_cidr" {
  type        = string
  default     = "10.0.128.0/24"
  description = "CIDR for offensive hosts"
}

variable "interface_endpoint_subnet_cidr" {
  type        = string
  default     = "10.0.130.0/28"
  description = "CIDR for optional interface endpoints"
}

variable "vectr_subnet_cidr" {
  type        = string
  default     = "10.0.130.16/28"
  description = "CIDR for the private VECTR host"
}

variable "nat_subnet_cidr" {
  type        = string
  default     = "10.0.130.32/28"
  description = "CIDR for the public NAT gateway subnet"
}

variable "vpn_cidr" {
  type        = string
  default     = "172.31.252.0/22"
  description = "CIDR allocated to Client VPN clients"

  validation {
    condition = (
      can(cidrhost(var.vpn_cidr, 0))
      && can(cidrhost(var.vpc_cidr, 0))
      && split(".", var.vpn_cidr)[0] != split(".", var.vpc_cidr)[0]
    )
    error_message = "vpn_cidr must be valid IPv4 CIDR in a different /8 from vpc_cidr so the ranges cannot overlap."
  }
}

variable "enable_ssm_endpoints" {
  type        = bool
  default     = false
  description = "Create the three paid Systems Manager interface endpoints"
}

variable "enable_vpn" {
  type        = bool
  default     = true
  description = "Create the AWS Client VPN endpoint"
}

variable "vpn_logging_enabled" {
  type        = bool
  default     = true
  description = "Send Client VPN connection logs to CloudWatch Logs"
}

variable "kali_count" {
  type        = number
  default     = 1
  description = "Number of private Kali instances"

  validation {
    condition     = var.kali_count >= 0 && floor(var.kali_count) == var.kali_count
    error_message = "kali_count must be a non-negative integer."
  }
}

variable "enable_vectr" {
  type        = bool
  default     = true
  description = "Create the private VECTR host and durable data volume"

  validation {
    condition     = !var.enable_vectr || var.enable_vpn
    error_message = "enable_vectr requires enable_vpn because VECTR is reachable only through Client VPN."
  }
}

variable "vectr_version" {
  type        = string
  default     = "9.14.1"
  description = "Pinned VECTR Community Edition release"
}

variable "vectr_release_sha256" {
  type        = string
  default     = "8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22"
  description = "SHA-256 digest of the pinned VECTR runtime zip"
}

variable "name_prefix" {
  type        = string
  default     = "thunderdome"
  description = "Prefix used for resource names"
}

variable "common_tags" {
  type = map(string)
  default = {
    Project   = "thunderdome"
    ManagedBy = "terraform"
  }
  description = "Tags applied to all AWS resources"
}
