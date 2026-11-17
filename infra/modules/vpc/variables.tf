# Variables for the VPC

variable "vpc_region" {
  type        = string
  default     = "us-east-1"
  description = "The region the VPC will be provisioned in"
}

variable "vpc_availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "The AWS availability_zone that the resources will be provisioned in"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The overall size of the VPC"
}

variable "offense_subnet_cidr" {
  type        = string
  default     = "10.0.128.0/24"
  description = "The CIDR block for the Offense subnet"
}

variable "vuln_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/17"
  description = "The CIDR block for the Vulnerable subnet"
}

variable "vectr_subnet_cidr" {
  type        = string
  default     = "10.0.130.16/28"
  description = "The CIDR block for the private VECTR subnet"
}

variable "interface_endpoint_subnet_cidr" {
  type        = string
  default     = "10.0.130.0/28"
  description = "The CIDR block for the Interface Endpoint subnet"
}

variable "nat_subnet_cidr" {
  type        = string
  default     = "10.0.130.32/28"
  description = "The CIDR block for the NAT subnet"
}
