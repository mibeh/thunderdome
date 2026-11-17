provider "aws" {
  region              = var.vpc_region
  allowed_account_ids = [var.expected_aws_account_id]

  default_tags {
    tags = var.common_tags
  }
}

data "aws_caller_identity" "current" {}

resource "terraform_data" "account_guard" {
  input = data.aws_caller_identity.current.account_id

  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.expected_aws_account_id
      error_message = "Refusing to deploy: authenticated AWS account does not match expected_aws_account_id."
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_region                     = var.vpc_region
  vpc_availability_zone          = var.vpc_availability_zone
  vpc_cidr                       = var.vpc_cidr
  vuln_subnet_cidr               = var.vuln_subnet_cidr
  offense_subnet_cidr            = var.offense_subnet_cidr
  vectr_subnet_cidr              = var.vectr_subnet_cidr
  interface_endpoint_subnet_cidr = var.interface_endpoint_subnet_cidr
  nat_subnet_cidr                = var.nat_subnet_cidr

  depends_on = [terraform_data.account_guard]
}

module "client_vpn" {
  source = "./modules/client-vpn"

  vpn_enabled           = var.enable_vpn
  vpn_logging_enabled   = var.vpn_logging_enabled
  vpn_endpoint_cidr     = var.vpn_cidr
  vpc_cidr              = var.vpc_cidr
  vpc_dns_server        = cidrhost(var.vpc_cidr, 2)
  vpc_id                = module.vpc.vpc_id
  association_subnet_id = module.vpc.offense_subnet_id
  vpn_security_group_id = module.vpc.vpn_endpoint_sec_group_id
  name_prefix           = var.name_prefix
  common_tags           = var.common_tags

  depends_on = [terraform_data.account_guard]
}

module "ssm" {
  source = "./modules/ssm"

  enable_ssm_endpoints       = var.enable_ssm_endpoints
  vpc_id                     = module.vpc.vpc_id
  vpc_region                 = var.vpc_region
  interface_endpoints_subnet = module.vpc.endpoint_subnet_id
  vpc_endpoint_sec_group     = module.vpc.vpc_endpoint_security_group

  depends_on = [terraform_data.account_guard]
}

module "kali" {
  source = "./modules/kali"

  instance_count    = var.kali_count
  offense_sec_group = module.vpc.offense_security_group
  offense_subnet    = module.vpc.offense_subnet_id
  name_prefix       = var.name_prefix
  common_tags       = var.common_tags

  depends_on = [terraform_data.account_guard]
}

module "vectr" {
  source = "./modules/vectr"

  enabled              = var.enable_vectr
  availability_zone    = var.vpc_availability_zone
  vectr_sec_group      = module.vpc.vectr_security_group
  vectr_subnet         = module.vpc.vectr_subnet_id
  vpc_id               = module.vpc.vpc_id
  vectr_version        = var.vectr_version
  vectr_release_sha256 = var.vectr_release_sha256
  name_prefix          = var.name_prefix
  common_tags          = var.common_tags

  depends_on = [terraform_data.account_guard]
}
