## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.client_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.client_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ec2_client_vpn_authorization_rule.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_acm_certificate.vpn_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_association_subnet_id"></a> [association\_subnet\_id](#input\_association\_subnet\_id) | Private subnet associated with the Client VPN endpoint | `string` | n/a |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags applied to Client VPN resources | `map(string)` | `{}` |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for Client VPN resource names | `string` | `"thunderdome"` |
| <a name="input_server_certificate_domain"></a> [server\_certificate\_domain](#input\_server\_certificate\_domain) | Domain on the imported ACM server certificate | `string` | `"server.thunderdome.lab"` |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR authorized for Client VPN access | `string` | n/a |
| <a name="input_vpc_dns_server"></a> [vpc\_dns\_server](#input\_vpc\_dns\_server) | VPC Route 53 Resolver address advertised to VPN clients | `string` | n/a |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC that owns the Client VPN target network | `string` | n/a |
| <a name="input_vpn_enabled"></a> [vpn\_enabled](#input\_vpn\_enabled) | Create the AWS Client VPN endpoint when true | `bool` | n/a |
| <a name="input_vpn_endpoint_cidr"></a> [vpn\_endpoint\_cidr](#input\_vpn\_endpoint\_cidr) | CIDR allocated to Client VPN clients | `string` | n/a |
| <a name="input_vpn_logging_enabled"></a> [vpn\_logging\_enabled](#input\_vpn\_logging\_enabled) | Send Client VPN connection logs to CloudWatch Logs | `bool` | `true` |
| <a name="input_vpn_security_group_id"></a> [vpn\_security\_group\_id](#input\_vpn\_security\_group\_id) | Security group assigned natively to the Client VPN endpoint | `string` | n/a |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | Client VPN endpoint ID, or null when VPN is disabled |
| <a name="output_vpn_endpoint_cidr"></a> [vpn\_endpoint\_cidr](#output\_vpn\_endpoint\_cidr) | CIDR allocated to Client VPN clients |
