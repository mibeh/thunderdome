variable "dmz_sec_group" {
  type        = string
  description = "The security group for DMZ instances"
}

variable "vectr_instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "The instance type for the VECTR instance"
}

variable "enabled" {
  type        = bool
  description = "If true, enables the VECTR instance"
}

variable "dmz_subnet" {
  type        = string
  description = "The subnet for DMZ instances"
}