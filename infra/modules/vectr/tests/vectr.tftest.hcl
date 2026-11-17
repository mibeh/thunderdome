mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-ubuntu-jammy"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1a"
    }
  }
}

variables {
  enabled           = true
  availability_zone = "us-east-1a"
  vectr_sec_group   = "sg-vectr"
  vectr_subnet      = "subnet-vectr"
  vpc_id            = "vpc-thunderdome"
}

run "private_durable_vectr" {
  command = plan

  assert {
    condition     = toset(data.aws_ami.ubuntu[0].owners) == toset(["099720109477"])
    error_message = "VECTR must use a Canonical-owned Ubuntu AMI."
  }

  assert {
    condition = anytrue([
      for filter in data.aws_ami.ubuntu[0].filter :
      filter.name == "name" && toset(filter.values) == toset(["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"])
    ])
    error_message = "VECTR must use the Canonical Ubuntu 22.04 x86-64 server image."
  }

  assert {
    condition     = aws_instance.vectr[0].instance_type == "t3a.large" && !aws_instance.vectr[0].associate_public_ip_address
    error_message = "VECTR must be a private t3a.large instance by default."
  }

  assert {
    condition = (
      one(aws_instance.vectr[0].root_block_device).encrypted
      && one(aws_instance.vectr[0].root_block_device).volume_type == "gp3"
    )
    error_message = "The VECTR root disk must be encrypted gp3 storage."
  }

  assert {
    condition = (
      length(aws_ebs_volume.vectr_data) == 1
      && aws_ebs_volume.vectr_data[0].encrypted
      && aws_ebs_volume.vectr_data[0].type == "gp3"
      && aws_ebs_volume.vectr_data[0].size == 100
      && aws_ebs_volume.vectr_data[0].availability_zone == "us-east-1a"
      && length(aws_volume_attachment.vectr_data) == 1
    )
    error_message = "VECTR data must use a separate encrypted 100 GiB gp3 volume."
  }

  assert {
    condition = (
      one(aws_instance.vectr[0].metadata_options).http_endpoint == "enabled"
      && one(aws_instance.vectr[0].metadata_options).http_tokens == "required"
    )
    error_message = "VECTR must require IMDSv2."
  }

  assert {
    condition = (
      aws_instance.vectr[0].iam_instance_profile == "thunderdome-vectr"
      && aws_iam_role_policy_attachment.vectr_ssm[0].policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    )
    error_message = "VECTR must attach the Systems Manager instance profile."
  }

  assert {
    condition = (
      one(aws_route53_zone.vectr[0].vpc).vpc_id == "vpc-thunderdome"
      && aws_route53_record.vectr[0].name == "thunderdome.lab"
      && aws_route53_record.vectr[0].type == "A"
    )
    error_message = "VECTR must publish an A record in a VPC-only private hosted zone."
  }

  assert {
    condition     = var.vectr_version == "9.14.1" && output.url == "https://thunderdome.lab:8081"
    error_message = "VECTR must default to release 9.14.1 at the private VPN URL."
  }
}

run "disabled_vectr" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition = (
      length(data.aws_ami.ubuntu) == 0
      && length(aws_iam_role.vectr) == 0
      && length(aws_iam_instance_profile.vectr) == 0
      && length(aws_instance.vectr) == 0
      && length(aws_ebs_volume.vectr_data) == 0
      && length(aws_volume_attachment.vectr_data) == 0
      && length(aws_route53_zone.vectr) == 0
      && length(aws_route53_record.vectr) == 0
    )
    error_message = "Disabling VECTR must create no VECTR resources or data lookups."
  }

  assert {
    condition     = output.url == null && output.private_ip == null
    error_message = "Disabled VECTR outputs must be null."
  }
}
