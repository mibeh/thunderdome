# Variables for the VPC

variable "vpc_region" {
  type        = string
  default     = "us-east-1"
  description = "The region the VPC will be provisioned in"
}

variable "enable_ssm" {
  default     = true
  description = "If set to true, enable auto scaling"
  type        = bool
}

variable "enable_vpn" {
  default     = true
  description = "If set to true, enable auto scaling"
  type        = bool
}

variable "kali_count" {
  description = "If set to true, enable auto scaling"
  default     = 0
  type        = number
}

variable "enable_vectr" {
  description = "If set to true, enable auto scaling"
  default     = false
  type        = bool
}
