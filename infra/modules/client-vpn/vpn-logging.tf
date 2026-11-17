resource "aws_cloudwatch_log_group" "client_vpn" {
  count = var.vpn_enabled && var.vpn_logging_enabled ? 1 : 0

  name              = "/thunderdome/client-vpn"
  retention_in_days = 30

  tags = var.common_tags
}

resource "aws_cloudwatch_log_stream" "client_vpn" {
  count = var.vpn_enabled && var.vpn_logging_enabled ? 1 : 0

  name           = "connections"
  log_group_name = aws_cloudwatch_log_group.client_vpn[0].name
}
