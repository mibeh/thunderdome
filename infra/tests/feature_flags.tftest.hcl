mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111122223333"
      arn        = "arn:aws:iam::111122223333:user/terraform-test"
      user_id    = "AIDATEST"
    }
  }

  mock_data "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:111122223333:certificate/vpn"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id = "ami-test"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1a"
    }
  }
}

variables {
  expected_aws_account_id = "111122223333"
}

run "default_features" {
  command = plan

  assert {
    condition = (
      var.enable_vpn
      && var.enable_vectr
      && var.kali_count == 1
      && !var.enable_ssm_endpoints
      && var.vpn_cidr == "172.31.252.0/22"
    )
    error_message = "Defaults must enable VPN, VECTR, and one Kali instance while leaving paid SSM endpoints disabled."
  }

  assert {
    condition     = length(module.kali.instance_ids) == 1 && module.vectr.url == "https://thunderdome.lab:8081"
    error_message = "The default plan must produce one Kali instance and the private VECTR URL."
  }
}

run "overlapping_vpn_pool_rejected" {
  command = plan

  variables {
    vpn_cidr = "10.0.132.0/22"
  }

  expect_failures = [var.vpn_cidr]
}

run "vpn_and_vectr_disabled" {
  command = plan

  variables {
    enable_vpn   = false
    enable_vectr = false
  }

  assert {
    condition     = module.client_vpn.client_vpn_endpoint_id == null && module.vectr.url == null
    error_message = "VPN and VECTR must both be omittable without absent-index failures."
  }
}

run "vectr_disabled" {
  command = plan

  variables {
    enable_vectr = false
  }

  assert {
    condition     = module.vectr.url == null
    error_message = "VECTR must be independently omittable while Client VPN remains enabled."
  }
}

run "kali_disabled" {
  command = plan

  variables {
    kali_count = 0
  }

  assert {
    condition     = length(module.kali.instance_ids) == 0 && length(module.kali.ssm_session_commands) == 0
    error_message = "A zero Kali count must produce no Kali instances or session commands."
  }
}

run "ssm_endpoints_disabled" {
  command = plan

  variables {
    enable_ssm_endpoints = false
  }

  assert {
    condition     = length(module.ssm.endpoint_ids) == 0
    error_message = "Paid Systems Manager interface endpoints must remain absent when disabled."
  }
}

run "wrong_account_rejected" {
  command = plan

  variables {
    expected_aws_account_id = "999988887777"
  }

  expect_failures = [terraform_data.account_guard]
}

run "vectr_requires_vpn" {
  command = plan

  variables {
    enable_vpn   = false
    enable_vectr = true
  }

  expect_failures = [var.enable_vectr]
}
