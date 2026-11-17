locals {
  resource_tags = merge(var.common_tags, {
    Component = "vectr"
  })
}

data "aws_ami" "ubuntu" {
  count = var.enabled ? 1 : 0

  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

resource "aws_iam_role" "vectr" {
  count = var.enabled ? 1 : 0

  name = "${var.name_prefix}-vectr"
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

resource "aws_iam_role_policy_attachment" "vectr_ssm" {
  count = var.enabled ? 1 : 0

  role       = aws_iam_role.vectr[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "vectr" {
  count = var.enabled ? 1 : 0

  name = "${var.name_prefix}-vectr"
  role = aws_iam_role.vectr[0].name

  tags = local.resource_tags
}

resource "aws_instance" "vectr" {
  count = var.enabled ? 1 : 0

  ami                         = data.aws_ami.ubuntu[0].id
  instance_type               = var.vectr_instance_type
  vpc_security_group_ids      = [var.vectr_sec_group]
  subnet_id                   = var.vectr_subnet
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.vectr[0].name
  user_data = templatefile("${path.module}/cloud-init.sh.tftpl", {
    data_device_name      = var.data_device_name
    data_filesystem_label = var.data_filesystem_label
    data_mount_path       = var.data_mount_path
    data_volume_id        = aws_ebs_volume.vectr_data[0].id
    vectr_release_sha256  = var.vectr_release_sha256
    vectr_version         = var.vectr_version
    zone_name             = var.zone_name
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
    volume_size           = 30
    volume_type           = "gp3"

    tags = merge(local.resource_tags, {
      Name = "${var.name_prefix}-vectr-root"
    })
  }

  tags = merge(local.resource_tags, {
    Name = "${var.name_prefix}-vectr"
  })

  depends_on = [aws_iam_role_policy_attachment.vectr_ssm]
}

resource "aws_ebs_volume" "vectr_data" {
  count = var.enabled ? 1 : 0

  availability_zone = var.availability_zone
  encrypted         = true
  size              = var.data_volume_size
  type              = "gp3"

  tags = merge(local.resource_tags, {
    Name = "${var.name_prefix}-vectr-data"
  })
}

resource "aws_volume_attachment" "vectr_data" {
  count = var.enabled ? 1 : 0

  device_name                    = var.data_device_name
  instance_id                    = aws_instance.vectr[0].id
  volume_id                      = aws_ebs_volume.vectr_data[0].id
  stop_instance_before_detaching = true
}

resource "aws_route53_zone" "vectr" {
  count = var.enabled ? 1 : 0

  name = var.zone_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = local.resource_tags
}

resource "aws_route53_record" "vectr" {
  count = var.enabled ? 1 : 0

  zone_id = aws_route53_zone.vectr[0].zone_id
  name    = var.zone_name
  type    = "A"
  ttl     = 60
  records = [aws_instance.vectr[0].private_ip]
}
