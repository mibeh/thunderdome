mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-official-kali"
    }
  }

}

variables {
  instance_count    = 1
  offense_sec_group = "sg-offense"
  offense_subnet    = "subnet-offense"
}

run "official_private_kali" {
  command = plan

  assert {
    condition     = length(data.aws_ami.kali) == 1
    error_message = "An enabled Kali deployment must query exactly one official AMI."
  }

  assert {
    condition = anytrue([
      for filter in data.aws_ami.kali[0].filter :
      filter.name == "product-code" && toset(filter.values) == toset(["7lgvy7mt78lgoi4lant0znp5h"])
    ])
    error_message = "Kali AMI discovery must pin the official Marketplace product code."
  }

  assert {
    condition = anytrue([
      for filter in data.aws_ami.kali[0].filter :
      filter.name == "name" && toset(filter.values) == toset(["debian-kali-last-snapshot-amd64-*"])
    ])
    error_message = "Kali AMI discovery must use the official current snapshot name pattern."
  }

  assert {
    condition     = aws_instance.kali[0].instance_type == "t3a.medium"
    error_message = "Kali must default to t3a.medium."
  }

  assert {
    condition     = !aws_instance.kali[0].associate_public_ip_address
    error_message = "Kali must not receive a public IP address."
  }

  assert {
    condition = (
      one(aws_instance.kali[0].root_block_device).encrypted
      && one(aws_instance.kali[0].root_block_device).volume_type == "gp3"
      && one(aws_instance.kali[0].root_block_device).volume_size == 40
    )
    error_message = "Kali must use an encrypted 40 GiB gp3 root volume."
  }

  assert {
    condition = (
      one(aws_instance.kali[0].metadata_options).http_endpoint == "enabled"
      && one(aws_instance.kali[0].metadata_options).http_tokens == "required"
    )
    error_message = "Kali must require IMDSv2."
  }

  assert {
    condition = (
      aws_instance.kali[0].iam_instance_profile == "thunderdome-kali"
      && aws_iam_role_policy_attachment.kali_ssm[0].policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    )
    error_message = "Kali must attach the Systems Manager instance profile."
  }

  assert {
    condition     = length(output.instance_ids) == 1 && length(output.ssm_session_commands) == 1
    error_message = "Enabled Kali instances must produce IDs and SSM session commands."
  }
}

run "disabled_kali" {
  command = plan

  variables {
    instance_count = 0
  }

  assert {
    condition = (
      length(data.aws_ami.kali) == 0
      && length(aws_iam_role.kali) == 0
      && length(aws_iam_role_policy_attachment.kali_ssm) == 0
      && length(aws_iam_instance_profile.kali) == 0
      && length(aws_instance.kali) == 0
    )
    error_message = "A zero instance count must create no Kali resources or AMI query."
  }

  assert {
    condition     = length(output.instance_ids) == 0 && length(output.ssm_session_commands) == 0
    error_message = "A zero instance count must return empty Kali outputs."
  }
}
