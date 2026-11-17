output "endpoint_ids" {
  value       = [for endpoint in aws_vpc_endpoint.ssm_endpoints : endpoint.id]
  description = "Systems Manager interface endpoint IDs, empty when endpoints are disabled"
}
