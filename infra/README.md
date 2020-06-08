## Requirements

| Name | Version |
|------|---------|
| aws | ~> 2.64 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable\_ssm | If set to true, enables SSM | `bool` | `true` |
| enable\_vectr | If set to true, deploys a public-facing instance of VECTR | `bool` | `false` |
| enable\_vpn | If set to true, enables the Client VPN Endpoint | `bool` | `true` |
| kali\_count | The number of Kali instances to deploy | `number` | `0` |
| vpc\_region | The region the VPC will be provisioned in | `string` | `"us-east-1"` |

## Outputs

| Name | Description |
|------|-------------|
| NETWORK\_ENDPOINTS | The CIDR block for the VPC endpoints subnet |
| NETWORK\_NAT | The CIDR block for the NAT subnet |
| NETWORK\_VPC | The CIDR block of the VPC |
| NETWORK\_VULN | The CIDR block for the vulnerable subnet |
| NETWORK\_offense | The CIDR block for the offense subnet |
| VPC\_ID | The vpc-id |

