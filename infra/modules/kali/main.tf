locals {
  kali_enabled = var.instance_count > 0
  resource_tags = merge(var.common_tags, {
    Component = "kali"
  })
}

data "aws_ami" "kali" {
  count = local.kali_enabled ? 1 : 0

  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["debian-kali-last-snapshot-amd64-*"]
  }

  filter {
    name   = "product-code"
    values = ["7lgvy7mt78lgoi4lant0znp5h"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "kali" {
  count = local.kali_enabled ? 1 : 0

  name = "${var.name_prefix}-kali"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.resource_tags
}

resource "aws_iam_role_policy_attachment" "kali_ssm" {
  count = local.kali_enabled ? 1 : 0

  role       = aws_iam_role.kali[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "kali" {
  count = local.kali_enabled ? 1 : 0

  name = "${var.name_prefix}-kali"
  role = aws_iam_role.kali[0].name

  tags = local.resource_tags
}

resource "aws_instance" "kali" {
  count = var.instance_count

  ami                         = data.aws_ami.kali[0].id
  instance_type               = var.kali_instance_type
  vpc_security_group_ids      = [var.offense_sec_group]
  subnet_id                   = var.offense_subnet
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.kali[0].name
  user_data = templatefile("${path.module}/cloud-init.sh.tftpl", {
    kali_metapackage = var.kali_metapackage
  })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 40
    volume_type           = "gp3"

    tags = merge(local.resource_tags, {
      Name = "${var.name_prefix}-kali-${count.index + 1}-root"
    })
  }

  tags = merge(local.resource_tags, {
    Name = "${var.name_prefix}-kali-${count.index + 1}"
  })

  depends_on = [aws_iam_role_policy_attachment.kali_ssm]
}
