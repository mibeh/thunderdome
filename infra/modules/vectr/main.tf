# Get most recent attack instance AMI id
data "aws_ami" "vectr" {

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["thunderdome_vectr_centos_7*"]
  }
}

# VECTR Instance
resource "aws_instance" "vectr" {

  count                  = var.enabled ? 1 : 0
  ami                    = data.aws_ami.vectr.id
  instance_type          = var.vectr_instance_type
  vpc_security_group_ids = [var.dmz_sec_group]
  subnet_id              = var.dmz_subnet
  user_data              = file("${path.module}/vectr_user_data.sh")

  tags = {
    Name = "Thunderdome VECTR"
  }
}