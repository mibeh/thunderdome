mock_provider "aws" {}

variables {
  enable_ssm_endpoints       = true
  interface_endpoints_subnet = "subnet-endpoints"
  vpc_endpoint_sec_group     = "sg-endpoints"
  vpc_id                     = "vpc-thunderdome"
  vpc_region                 = "us-east-1"
}

run "enabled_endpoints" {
  command = plan

  assert {
    condition     = length(aws_vpc_endpoint.ssm_endpoints) == 3
    error_message = "Enabling SSM endpoints must create exactly three interface endpoints."
  }

  assert {
    condition = toset(keys(aws_vpc_endpoint.ssm_endpoints)) == toset([
      "ec2messages",
      "ssm",
      "ssmmessages",
    ])
    error_message = "Only the SSM, EC2 Messages, and SSM Messages endpoints may be created."
  }

  assert {
    condition = alltrue([
      for endpoint in aws_vpc_endpoint.ssm_endpoints : endpoint.private_dns_enabled
    ])
    error_message = "Every SSM interface endpoint must enable private DNS."
  }

  assert {
    condition = alltrue([
      for endpoint in aws_vpc_endpoint.ssm_endpoints : endpoint.security_group_ids == toset(["sg-endpoints"])
    ])
    error_message = "Every SSM interface endpoint must use the dedicated endpoint security group."
  }

  assert {
    condition = alltrue([
      for name, endpoint in aws_vpc_endpoint.ssm_endpoints : endpoint.service_name == "com.amazonaws.us-east-1.${name}"
    ])
    error_message = "SSM endpoint service names must match their expected regional services."
  }
}

run "disabled_endpoints" {
  command = plan

  variables {
    enable_ssm_endpoints = false
  }

  assert {
    condition     = length(aws_vpc_endpoint.ssm_endpoints) == 0
    error_message = "Disabling SSM endpoints must create no paid interface endpoints."
  }
}
