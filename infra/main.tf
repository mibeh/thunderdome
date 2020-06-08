provider "aws" {
  profile    = "default"
  version    = "~> 2.64"
  region     = var.vpc_region
}

module "vpc" {

  source   = "./modules/vpc"
  vpn_cidr = module.client-vpn.vpn_endpoint_cidr
}

module "client-vpn" {

  source                     = "./modules/client-vpn"
  vpn_enabled                = var.enable_vpn
  vuln_subnet_id             = module.vpc.vuln_subnet_id
  vuln_subnet_name           = module.vpc.vuln_subnet_name
  vpc_id                     = module.vpc.vpc_id
  vpn_endpoint_sec_group_id  = module.vpc.vpn_endpoint_sec_group_id
  offense_subnet_id          = module.vpc.offense_subnet_id
  interface_endpoints_subnet = module.vpc.endpoint_subnet_id
  vpc_endpoint_sec_group     = module.vpc.vpn_endpoint_sec_group_id
  vpc_region                 = var.vpc_region
}

module "ssm" {

  source                     = "./modules/ssm"
  enabled                    = var.enable_ssm
  vpc_id                     = module.vpc.vpc_id
  vpc_region                 = var.vpc_region
  interface_endpoints_subnet = module.vpc.endpoint_subnet_id
  vpc_endpoint_sec_group     = module.vpc.vpn_endpoint_sec_group_id
}

module "kali" {

  source            = "./modules/kali"
  instance_count    = var.kali_count
  offense_sec_group = module.vpc.offense_security_group
  offense_subnet    = module.vpc.offense_subnet_id
}


module "vectr" {

  source        = "./modules/vectr"
  enabled       = var.enable_vectr
  dmz_sec_group = module.vpc.dmz_security_group
  dmz_subnet    = module.vpc.dmz_subnet_id
}
