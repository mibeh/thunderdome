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
| [aws_iam_instance_profile.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.kali_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.kali](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags applied to Kali resources | `map(string)` | `{}` |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of Kali instances to deploy | `number` | n/a |
| <a name="input_kali_instance_type"></a> [kali\_instance\_type](#input\_kali\_instance\_type) | The instance type for Kali instances | `string` | `"t3a.medium"` |
| <a name="input_kali_metapackage"></a> [kali\_metapackage](#input\_kali\_metapackage) | The Kali metapackage installed after Systems Manager is available | `string` | `"kali-linux-default"` |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for Kali resource names | `string` | `"thunderdome"` |
| <a name="input_offense_sec_group"></a> [offense\_sec\_group](#input\_offense\_sec\_group) | The security group for offensive instances | `string` | n/a |
| <a name="input_offense_subnet"></a> [offense\_subnet](#input\_offense\_subnet) | The private subnet for offensive instances | `string` | n/a |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the private Kali instances |
| <a name="output_ssm_session_commands"></a> [ssm\_session\_commands](#output\_ssm\_session\_commands) | Commands that start Systems Manager sessions to Kali instances |
