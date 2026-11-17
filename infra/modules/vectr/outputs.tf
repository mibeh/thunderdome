output "instance_id" {
  value       = try(aws_instance.vectr[0].id, null)
  description = "ID of the private VECTR instance, or null when disabled"
}

output "private_ip" {
  value       = try(aws_instance.vectr[0].private_ip, null)
  description = "Private IP address of VECTR, or null when disabled"
}

output "url" {
  value       = var.enabled ? "https://${var.zone_name}:8081" : null
  description = "VECTR URL reachable through Client VPN, or null when disabled"
}

output "data_volume_id" {
  value       = try(aws_ebs_volume.vectr_data[0].id, null)
  description = "ID of the separate durable VECTR data volume, or null when disabled"
}
