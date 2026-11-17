mock_provider "aws" {
  mock_data "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:111122223333:certificate/vpn"
    }
  }
}

variables {
  vpn_enabled           = true
  vpn_logging_enabled   = true
  vpn_endpoint_cidr     = "172.16.0.0/22"
  vpc_cidr              = "10.42.0.0/16"
  vpc_dns_server        = "10.42.0.2"
  vpc_id                = "vpc-thunderdome"
  association_subnet_id = "subnet-offense"
  vpn_security_group_id = "sg-vpn"
}

run "native_client_vpn" {
  command = plan

  assert {
    condition     = length(data.aws_acm_certificate.vpn_certificate) == 1
    error_message = "An enabled Client VPN must query exactly one imported ACM certificate."
  }

  assert {
    condition = (
      length(aws_cloudwatch_log_group.client_vpn) == 1
      && length(aws_cloudwatch_log_stream.client_vpn) == 1
      && one(aws_ec2_client_vpn_endpoint.this[0].connection_log_options).enabled
    )
    error_message = "Enabled VPN logging must create one log group and stream and enable endpoint logging."
  }

  assert {
    condition = (
      aws_ec2_client_vpn_authorization_rule.vpc[0].target_network_cidr == "10.42.0.0/16"
      && aws_ec2_client_vpn_authorization_rule.vpc[0].authorize_all_groups
    )
    error_message = "Client VPN authorization must grant all certificate-authenticated clients access to the configured VPC CIDR."
  }

  assert {
    condition = (
      aws_ec2_client_vpn_network_association.this[0].subnet_id == "subnet-offense"
      && length(aws_ec2_client_vpn_endpoint.this[0].security_group_ids) == 1
      && contains(aws_ec2_client_vpn_endpoint.this[0].security_group_ids, "sg-vpn")
      && length(aws_ec2_client_vpn_endpoint.this[0].dns_servers) == 1
      && contains(aws_ec2_client_vpn_endpoint.this[0].dns_servers, "10.42.0.2")
    )
    error_message = "The target subnet, security group, and VPC resolver must be configured with native Client VPN arguments."
  }

  assert {
    condition     = output.vpn_endpoint_cidr == "172.16.0.0/22"
    error_message = "The module must return the configured Client VPN CIDR."
  }
}

run "vpn_without_logging" {
  command = plan

  variables {
    vpn_logging_enabled = false
  }

  assert {
    condition = (
      length(aws_cloudwatch_log_group.client_vpn) == 0
      && length(aws_cloudwatch_log_stream.client_vpn) == 0
      && !one(aws_ec2_client_vpn_endpoint.this[0].connection_log_options).enabled
    )
    error_message = "Disabling VPN logging must omit CloudWatch resources and disable endpoint logging."
  }
}

run "disabled_client_vpn" {
  command = plan

  variables {
    vpn_enabled = false
  }

  assert {
    condition = (
      length(data.aws_acm_certificate.vpn_certificate) == 0
      && length(aws_ec2_client_vpn_endpoint.this) == 0
      && length(aws_ec2_client_vpn_network_association.this) == 0
      && length(aws_ec2_client_vpn_authorization_rule.vpc) == 0
      && length(aws_cloudwatch_log_group.client_vpn) == 0
      && length(aws_cloudwatch_log_stream.client_vpn) == 0
    )
    error_message = "Disabling Client VPN must create no endpoint, association, authorization, log resources, or certificate query."
  }

  assert {
    condition     = output.client_vpn_endpoint_id == null && output.vpn_endpoint_cidr == "172.16.0.0/22"
    error_message = "A disabled Client VPN must return a null endpoint ID without hiding the configured CIDR."
  }
}
