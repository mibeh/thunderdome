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
| [aws_vpc_endpoint.ssm_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_enable_ssm_endpoints"></a> [enable\_ssm\_endpoints](#input\_enable\_ssm\_endpoints) | Create the three paid interface endpoints used by Systems Manager | `bool` | `false` |
| <a name="input_interface_endpoints_subnet"></a> [interface\_endpoints\_subnet](#input\_interface\_endpoints\_subnet) | The subnet for interface endpoints | `string` | n/a |
| <a name="input_vpc_endpoint_sec_group"></a> [vpc\_endpoint\_sec\_group](#input\_vpc\_endpoint\_sec\_group) | The security group for VPC endpoints | `string` | n/a |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The vpc-id for Thunderdome VPC | `string` | n/a |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region the VPC will be provisioned in | `string` | n/a |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoint_ids"></a> [endpoint\_ids](#output\_endpoint\_ids) | Systems Manager interface endpoint IDs, empty when endpoints are disabled |
