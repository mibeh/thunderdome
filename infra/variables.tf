# Variables for the root module

variable "vpc_region" {
  type        = string
  default     = "us-east-1"
  description = "The region the VPC will be provisioned in"
}

variable "enable_ssm" {
  default     = true
  description = "If set to true, enables SSM"
  type        = bool
}

variable "enable_vpn" {
  default     = true
  description = "If set to true, enables the Client VPN Endpoint"
  type        = bool
}

variable "kali_count" {
  description = "The number of Kali instances to deploy"
  default     = 0
  type        = number
}

variable "enable_vectr" {
  description = "If set to true, deploys a public-facing instance of VECTR"
  default     = false
  type        = bool
}
