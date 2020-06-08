output "public_ip" {
	description = "The public IP of the instance"
	# Add 'thunderdome.lab' with new public IP to /etc/hosts
    value = "Run the following to add 'thunderdome.lab' to your hosts file: echo \"${aws_eip.vectr_public.public_ip} thunderdome.lab\" | sudo tee -a /etc/hosts"
}