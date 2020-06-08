## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| interface\_endpoints\_subnet | The subnet for VPC interface endpoints | `string` | n/a |
| offense\_subnet\_id | The id of the offense subnet resource | `string` | n/a |
| vpc\_endpoint\_sec\_group | The security group for VPC interface endpoints | `string` | n/a |
| vpc\_id | The id of the VPC resource | `string` | n/a |
| vpc\_region | The region the VPC is in | `string` | n/a |
| vpn\_enabled | If true, enables creates the VPC endpoints needed for SSM | `bool` | n/a |
| vpn\_endpoint\_cidr | The CIDR block for the VPN endpoints | `string` | `"10.0.132.0/22"` |
| vpn\_endpoint\_sec\_group\_id | The id of the VPN Endpoint resource | `string` | n/a |
| vpn\_logging\_enabled | Whether to enable logging of Client VPN connections | `bool` | `true` |
| vuln\_subnet\_cidr | The CIDR block for the Vulnerable subnet | `string` | `"10.0.0.0/17"` |
| vuln\_subnet\_id | The id of the vulnerable subnet resource | `string` | n/a |
| vuln\_subnet\_name | The name of the vulnerable subnet resource | `any` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| vpn\_endpoint\_cidr | The CIDR block for the VPN endpoints, needed for VPC module |
