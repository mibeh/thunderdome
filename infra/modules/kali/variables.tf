variable "offense_sec_group" {
  type        = string
  description = "The security group for offensive instances"
}

variable "offense_subnet" {
  type        = string
  description = "The private subnet for offensive instances"
}

variable "kali_instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "The instance type for Kali instances"
}

variable "instance_count" {
  type        = number
  description = "The number of Kali instances to deploy"

  validation {
    condition     = var.instance_count >= 0 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count must be a non-negative integer."
  }
}

variable "kali_metapackage" {
  type        = string
  default     = "kali-linux-default"
  description = "The Kali metapackage installed after Systems Manager is available"

  validation {
    condition     = contains(["kali-linux-default", "kali-linux-large"], var.kali_metapackage)
    error_message = "kali_metapackage must be kali-linux-default or kali-linux-large."
  }
}

variable "name_prefix" {
  type        = string
  default     = "thunderdome"
  description = "Prefix used for Kali resource names"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to Kali resources"
}
