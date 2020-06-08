# Systems Session Manager related VPC endpoints
# The SSM agent is pre-installed on the images
resource "aws_vpc_endpoint" "ssm" {
  count             = var.enabled ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = join(".", ["com.amazonaws", var.vpc_region, "ssm"])
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.interface_endpoints_subnet,
  ]
  security_group_ids = [
    var.vpc_endpoint_sec_group,
  ]
}

# EC2 Messages, needed for SSM
resource "aws_vpc_endpoint" "ec2messages" {
  count             = var.enabled ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = join(".", ["com.amazonaws", var.vpc_region, "ec2messages"])
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.interface_endpoints_subnet,
  ]
  security_group_ids = [
    var.vpc_endpoint_sec_group,
  ]
}

# SSM Messages, needed for SSM
resource "aws_vpc_endpoint" "ssmmessages" {
  count             = var.enabled ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = join(".", ["com.amazonaws", var.vpc_region, "ssmmessages"])
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.interface_endpoints_subnet,
  ]
  security_group_ids = [
    var.vpc_endpoint_sec_group,
  ]
}
