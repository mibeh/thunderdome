output "instance_ids" {
  value       = aws_instance.kali[*].id
  description = "IDs of the private Kali instances"
}

output "ssm_session_commands" {
  value = [
    for instance in aws_instance.kali : "aws ssm start-session --target ${instance.id}"
  ]
  description = "Commands that start Systems Manager sessions to Kali instances"
}
