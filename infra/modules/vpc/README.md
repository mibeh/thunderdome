## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| dmz\_subnet\_cidr | The CIDR block for the DMZ subnet | `string` | `"10.0.130.16/28"` |
| interface\_endpoint\_subnet\_cidr | The CIDR block for the Interface Endpoint subnet | `string` | `"10.0.130.0/28"` |
| nat\_subnet\_cidr | The CIDR block for the NAT subnet | `string` | `"10.0.130.32/28"` |
| offense\_instance\_iam\_profile | The IAM profile applied to the offense instance | `string` | `"offenseInstanceRole"` |
| offense\_subnet\_cidr | The CIDR block for the Offense subnet | `string` | `"10.0.128.0/24"` |
| vpc\_availability\_zone | The AWS availability\_zone that the resources will be provisioned in | `string` | `"us-east-1a"` |
| vpc\_cidr | The overall size of the VPC | `string` | `"10.0.0.0/16"` |
| vpc\_region | The region the VPC will be provisioned in | `string` | `"us-east-1"` |
| vpn\_cidr | The CIDR block for the VPN endpoints | `string` | n/a |
| vuln\_instance\_iam\_profile | The IAM profile applied to the vulnerable instances | `string` | `"VulnerableInstanceRole"` |
| vuln\_instance\_type | The type of instance to use for Windows Server 2016+ instances | `string` | `"t3a.small"` |
| vuln\_subnet\_cidr | The CIDR block for the Vulnerable subnet | `string` | `"10.0.0.0/17"` |

## Outputs

| Name | Description |
|------|-------------|
| NETWORK\_ENDPOINTS | The CIDR block for the VPC endpoints subnet, used to print to terminal |
| NETWORK\_NAT | The CIDR block for the NAT subnet, used to print to terminal |
| NETWORK\_VPC | The CIDR block of the VPC, used to print to terminal |
| NETWORK\_VULN | The CIDR block for the vulnerable subnet, used to print to terminal |
| NETWORK\_offense | The CIDR block for the offense subnet, used to print to terminal |
| dmz\_security\_group | The security group for DMZ instances |
| dmz\_subnet\_id | The subnet-id for the DMZ subnet |
| endpoint\_subnet\_id | The subnet-id for the interface endpoints subnet |
| offense\_security\_group | The security group for offense instances |
| offense\_subnet\_id | The subnet-id for the offense subnet |
| vpc\_endpoint\_security\_group | The security group for VPC endpoints |
| vpc\_id | The vpc-id for the VPC |
| vpn\_endpoint\_sec\_group\_id | The subnet-id for the vpc endpoints subnet |
| vuln\_subnet\_id | The subnet-id for the vulnerable subnet |
| vuln\_subnet\_name | The terraform resource name for the vulnerable subnet |

