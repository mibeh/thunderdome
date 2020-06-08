# Get most recent attack instance AMI id
data "aws_ami" "kali" {

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["thunderdome_kali_2019.4*"]
  }
}

# Kali Instance
resource "aws_instance" "kali" {

  count                  = var.instance_count
  ami                    = data.aws_ami.kali.id
  instance_type          = var.kali_instance_type
  vpc_security_group_ids = [var.offense_sec_group]
  subnet_id              = var.offense_subnet

  tags = {
    Name = "Thunderdome Kali ${count.index}"
  }
}
