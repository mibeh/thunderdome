variable "offense_sec_group" {
  type        = string
  description = "The security group for offensive instances"
}

variable "offense_subnet" {
  type        = string
  description = "The subnet for offensive instances"
}

variable "kali_instance_type" {
  type        = string
  default     = "t2.small"
  description = "The instance type for Kali instances"
}

variable "instance_count" {
  type        = number
  description = "The number of Kali instances to deploy"
}
