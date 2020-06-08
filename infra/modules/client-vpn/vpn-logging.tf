# Client VPN Endpoint connection logging

# Connection Logging for Client VPN Endpoint
resource "aws_cloudwatch_log_group" "thunderdome_vpn" {
  name              = "thunderdome_vpn"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "thunderdome_vpn_connections" {
  name           = "thunderdome_vpn_connection_logs"
  log_group_name = aws_cloudwatch_log_group.thunderdome_vpn.name
}

# CloudWatch VPC interface endpoint
resource "aws_vpc_endpoint" "monitoring" {
  vpc_id            = var.vpc_id
  service_name      = join(".", ["com.amazonaws", var.vpc_region, "monitoring"])
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.interface_endpoints_subnet
  ]
  security_group_ids = [
    var.vpc_endpoint_sec_group
  ]
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": "*",
      "Sid": "PutOnly",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}
