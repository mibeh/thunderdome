variable "vectr_sec_group" {
  type        = string
  description = "The security group for the private VECTR instance"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone shared by the VECTR instance and durable volume"
}

variable "vectr_subnet" {
  type        = string
  description = "The private subnet for the VECTR instance"
}

variable "vpc_id" {
  type        = string
  description = "The VPC where the private VECTR zone is associated"
}

variable "enabled" {
  type        = bool
  description = "Create the VECTR instance and supporting resources"
}

variable "vectr_instance_type" {
  type        = string
  default     = "t3a.large"
  description = "The instance type for VECTR"
}

variable "vectr_version" {
  type        = string
  default     = "9.14.1"
  description = "The pinned VECTR Community Edition release"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.vectr_version))
    error_message = "vectr_version must be a semantic version such as 9.14.1."
  }
}

variable "vectr_release_sha256" {
  type        = string
  default     = "8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22"
  description = "SHA-256 digest of the pinned VECTR runtime zip"

  validation {
    condition     = can(regex("^[0-9a-f]{64}$", var.vectr_release_sha256))
    error_message = "vectr_release_sha256 must be a lowercase 64-character SHA-256 digest."
  }
}

variable "zone_name" {
  type        = string
  default     = "thunderdome.lab"
  description = "Private Route 53 zone and VECTR hostname"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.zone_name))
    error_message = "zone_name must be a lowercase DNS name without a trailing dot."
  }
}

variable "data_volume_size" {
  type        = number
  default     = 100
  description = "Size in GiB of the durable VECTR data volume"

  validation {
    condition     = var.data_volume_size >= 100 && floor(var.data_volume_size) == var.data_volume_size
    error_message = "data_volume_size must be an integer of at least 100 GiB."
  }
}

variable "data_device_name" {
  type        = string
  default     = "/dev/sdf"
  description = "EC2 block device name requested for the durable data volume"

  validation {
    condition     = can(regex("^/dev/[A-Za-z0-9._/-]+$", var.data_device_name))
    error_message = "data_device_name must be an absolute path under /dev."
  }
}

variable "data_mount_path" {
  type        = string
  default     = "/opt/vectr"
  description = "Mount point for the durable VECTR data volume"

  validation {
    condition     = can(regex("^/[A-Za-z0-9._/-]+$", var.data_mount_path))
    error_message = "data_mount_path must be an absolute path containing only safe path characters."
  }
}

variable "data_filesystem_label" {
  type        = string
  default     = "VECTR_DATA"
  description = "Filesystem label assigned only when the data volume is blank"

  validation {
    condition     = can(regex("^[A-Z0-9_]{1,16}$", var.data_filesystem_label))
    error_message = "data_filesystem_label must be 1-16 uppercase letters, numbers, or underscores."
  }
}

variable "name_prefix" {
  type        = string
  default     = "thunderdome"
  description = "Prefix used for VECTR resource names"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to VECTR resources"
}
