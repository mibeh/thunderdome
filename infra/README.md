## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_client_vpn"></a> [client\_vpn](#module\_client\_vpn) | ./modules/client-vpn | n/a |
| <a name="module_kali"></a> [kali](#module\_kali) | ./modules/kali | n/a |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ./modules/ssm | n/a |
| <a name="module_vectr"></a> [vectr](#module\_vectr) | ./modules/vectr | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [terraform_data.account_guard](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags applied to all AWS resources | `map(string)` | <pre>{<br/>  "ManagedBy": "terraform",<br/>  "Project": "thunderdome"<br/>}</pre> |
| <a name="input_enable_ssm_endpoints"></a> [enable\_ssm\_endpoints](#input\_enable\_ssm\_endpoints) | Create the three paid Systems Manager interface endpoints | `bool` | `false` |
| <a name="input_enable_vectr"></a> [enable\_vectr](#input\_enable\_vectr) | Create the private VECTR host and durable data volume | `bool` | `true` |
| <a name="input_enable_vpn"></a> [enable\_vpn](#input\_enable\_vpn) | Create the AWS Client VPN endpoint | `bool` | `true` |
| <a name="input_expected_aws_account_id"></a> [expected\_aws\_account\_id](#input\_expected\_aws\_account\_id) | Twelve-digit AWS account ID allowed to receive this deployment | `string` | n/a |
| <a name="input_interface_endpoint_subnet_cidr"></a> [interface\_endpoint\_subnet\_cidr](#input\_interface\_endpoint\_subnet\_cidr) | CIDR for optional interface endpoints | `string` | `"10.0.130.0/28"` |
| <a name="input_kali_count"></a> [kali\_count](#input\_kali\_count) | Number of private Kali instances | `number` | `1` |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"thunderdome"` |
| <a name="input_nat_subnet_cidr"></a> [nat\_subnet\_cidr](#input\_nat\_subnet\_cidr) | CIDR for the public NAT gateway subnet | `string` | `"10.0.130.32/28"` |
| <a name="input_offense_subnet_cidr"></a> [offense\_subnet\_cidr](#input\_offense\_subnet\_cidr) | CIDR for offensive hosts | `string` | `"10.0.128.0/24"` |
| <a name="input_vectr_release_sha256"></a> [vectr\_release\_sha256](#input\_vectr\_release\_sha256) | SHA-256 digest of the pinned VECTR runtime zip | `string` | `"8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22"` |
| <a name="input_vectr_subnet_cidr"></a> [vectr\_subnet\_cidr](#input\_vectr\_subnet\_cidr) | CIDR for the private VECTR host | `string` | `"10.0.130.16/28"` |
| <a name="input_vectr_version"></a> [vectr\_version](#input\_vectr\_version) | Pinned VECTR Community Edition release | `string` | `"9.14.1"` |
| <a name="input_vpc_availability_zone"></a> [vpc\_availability\_zone](#input\_vpc\_availability\_zone) | Availability Zone for single-AZ range resources | `string` | `"us-east-1a"` |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR for the Thunderdome VPC | `string` | `"10.0.0.0/16"` |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | AWS region for the deployment | `string` | `"us-east-1"` |
| <a name="input_vpn_cidr"></a> [vpn\_cidr](#input\_vpn\_cidr) | CIDR allocated to Client VPN clients | `string` | `"172.31.252.0/22"` |
| <a name="input_vpn_logging_enabled"></a> [vpn\_logging\_enabled](#input\_vpn\_logging\_enabled) | Send Client VPN connection logs to CloudWatch Logs | `bool` | `true` |
| <a name="input_vuln_subnet_cidr"></a> [vuln\_subnet\_cidr](#input\_vuln\_subnet\_cidr) | CIDR for vulnerable targets | `string` | `"10.0.0.0/17"` |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_vpn_endpoint_id"></a> [client\_vpn\_endpoint\_id](#output\_client\_vpn\_endpoint\_id) | Client VPN endpoint ID, or null when VPN is disabled |
| <a name="output_endpoint_subnet_cidr"></a> [endpoint\_subnet\_cidr](#output\_endpoint\_subnet\_cidr) | Interface endpoint subnet CIDR |
| <a name="output_kali_instance_ids"></a> [kali\_instance\_ids](#output\_kali\_instance\_ids) | Private Kali instance IDs |
| <a name="output_kali_ssm_session_commands"></a> [kali\_ssm\_session\_commands](#output\_kali\_ssm\_session\_commands) | Commands that start Systems Manager sessions to Kali instances |
| <a name="output_nat_subnet_cidr"></a> [nat\_subnet\_cidr](#output\_nat\_subnet\_cidr) | Public NAT gateway subnet CIDR |
| <a name="output_offense_subnet_cidr"></a> [offense\_subnet\_cidr](#output\_offense\_subnet\_cidr) | Offensive host subnet CIDR |
| <a name="output_vectr_private_ip"></a> [vectr\_private\_ip](#output\_vectr\_private\_ip) | Private VECTR IP address, or null when VECTR is disabled |
| <a name="output_vectr_subnet_cidr"></a> [vectr\_subnet\_cidr](#output\_vectr\_subnet\_cidr) | Private VECTR subnet CIDR |
| <a name="output_vectr_url"></a> [vectr\_url](#output\_vectr\_url) | Private VECTR URL, or null when VECTR is disabled |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | Thunderdome VPC CIDR |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Thunderdome VPC ID |
| <a name="output_vulnerable_subnet_cidr"></a> [vulnerable\_subnet\_cidr](#output\_vulnerable\_subnet\_cidr) | Vulnerable target subnet CIDR |
