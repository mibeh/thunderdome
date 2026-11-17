variable "interface_endpoints_subnet" {
  type        = string
  description = "The subnet for interface endpoints"
}

variable "vpc_endpoint_sec_group" {
  type        = string
  description = "The security group for VPC endpoints"
}

variable "vpc_id" {
  type        = string
  description = "The vpc-id for Thunderdome VPC"
}

variable "vpc_region" {
  type        = string
  description = "The region the VPC will be provisioned in"
}

variable "enable_ssm_endpoints" {
  type        = bool
  description = "Create the three paid interface endpoints used by Systems Manager"
  default     = false
}
