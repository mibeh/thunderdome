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
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.vuln](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route_table.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.vuln](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.vuln](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpn_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vulnerable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.vuln](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.thunderdome_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.offense_dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.offense_dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.offense_to_vulnerable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.offense_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vectr_dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vectr_dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vectr_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vpn_to_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vulnerable_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vulnerable_dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vulnerable_dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.vulnerable_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.interface_endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.offense_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.offense_ssh_from_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vectr_from_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vulnerable_from_offense](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vulnerable_from_vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_interface_endpoint_subnet_cidr"></a> [interface\_endpoint\_subnet\_cidr](#input\_interface\_endpoint\_subnet\_cidr) | The CIDR block for the Interface Endpoint subnet | `string` | `"10.0.130.0/28"` |
| <a name="input_nat_subnet_cidr"></a> [nat\_subnet\_cidr](#input\_nat\_subnet\_cidr) | The CIDR block for the NAT subnet | `string` | `"10.0.130.32/28"` |
| <a name="input_offense_subnet_cidr"></a> [offense\_subnet\_cidr](#input\_offense\_subnet\_cidr) | The CIDR block for the Offense subnet | `string` | `"10.0.128.0/24"` |
| <a name="input_vectr_subnet_cidr"></a> [vectr\_subnet\_cidr](#input\_vectr\_subnet\_cidr) | The CIDR block for the private VECTR subnet | `string` | `"10.0.130.16/28"` |
| <a name="input_vpc_availability_zone"></a> [vpc\_availability\_zone](#input\_vpc\_availability\_zone) | The AWS availability\_zone that the resources will be provisioned in | `string` | `"us-east-1a"` |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The overall size of the VPC | `string` | `"10.0.0.0/16"` |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region the VPC will be provisioned in | `string` | `"us-east-1"` |
| <a name="input_vuln_subnet_cidr"></a> [vuln\_subnet\_cidr](#input\_vuln\_subnet\_cidr) | The CIDR block for the Vulnerable subnet | `string` | `"10.0.0.0/17"` |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_NETWORK_ENDPOINTS"></a> [NETWORK\_ENDPOINTS](#output\_NETWORK\_ENDPOINTS) | The CIDR block for the VPC endpoints subnet, used to print to terminal |
| <a name="output_NETWORK_NAT"></a> [NETWORK\_NAT](#output\_NETWORK\_NAT) | The CIDR block for the NAT subnet, used to print to terminal |
| <a name="output_NETWORK_VECTR"></a> [NETWORK\_VECTR](#output\_NETWORK\_VECTR) | The CIDR block for the private VECTR subnet, used to print to terminal |
| <a name="output_NETWORK_VPC"></a> [NETWORK\_VPC](#output\_NETWORK\_VPC) | The CIDR block of the VPC, used to print to terminal |
| <a name="output_NETWORK_VULN"></a> [NETWORK\_VULN](#output\_NETWORK\_VULN) | The CIDR block for the vulnerable subnet, used to print to terminal |
| <a name="output_NETWORK_offense"></a> [NETWORK\_offense](#output\_NETWORK\_offense) | The CIDR block for the offense subnet, used to print to terminal |
| <a name="output_endpoint_subnet_id"></a> [endpoint\_subnet\_id](#output\_endpoint\_subnet\_id) | The subnet-id for the interface endpoints subnet |
| <a name="output_offense_security_group"></a> [offense\_security\_group](#output\_offense\_security\_group) | The security group for offense instances |
| <a name="output_offense_subnet_id"></a> [offense\_subnet\_id](#output\_offense\_subnet\_id) | The subnet-id for the offense subnet |
| <a name="output_vectr_security_group"></a> [vectr\_security\_group](#output\_vectr\_security\_group) | The security group for the private VECTR instance |
| <a name="output_vectr_subnet_id"></a> [vectr\_subnet\_id](#output\_vectr\_subnet\_id) | The subnet ID for the private VECTR subnet |
| <a name="output_vpc_endpoint_security_group"></a> [vpc\_endpoint\_security\_group](#output\_vpc\_endpoint\_security\_group) | The security group for VPC endpoints |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The vpc-id for the VPC |
| <a name="output_vpn_endpoint_sec_group_id"></a> [vpn\_endpoint\_sec\_group\_id](#output\_vpn\_endpoint\_sec\_group\_id) | The security group for Client VPN target network associations |
| <a name="output_vuln_subnet_id"></a> [vuln\_subnet\_id](#output\_vuln\_subnet\_id) | The subnet-id for the vulnerable subnet |
| <a name="output_vuln_subnet_name"></a> [vuln\_subnet\_name](#output\_vuln\_subnet\_name) | The terraform resource name for the vulnerable subnet |
