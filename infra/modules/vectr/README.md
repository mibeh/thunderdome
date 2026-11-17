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
| [aws_ebs_volume.vectr_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vectr_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_record.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.vectr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_volume_attachment.vectr_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone shared by the VECTR instance and durable volume | `string` | n/a |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags applied to VECTR resources | `map(string)` | `{}` |
| <a name="input_data_device_name"></a> [data\_device\_name](#input\_data\_device\_name) | EC2 block device name requested for the durable data volume | `string` | `"/dev/sdf"` |
| <a name="input_data_filesystem_label"></a> [data\_filesystem\_label](#input\_data\_filesystem\_label) | Filesystem label assigned only when the data volume is blank | `string` | `"VECTR_DATA"` |
| <a name="input_data_mount_path"></a> [data\_mount\_path](#input\_data\_mount\_path) | Mount point for the durable VECTR data volume | `string` | `"/opt/vectr"` |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | Size in GiB of the durable VECTR data volume | `number` | `100` |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Create the VECTR instance and supporting resources | `bool` | n/a |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for VECTR resource names | `string` | `"thunderdome"` |
| <a name="input_vectr_instance_type"></a> [vectr\_instance\_type](#input\_vectr\_instance\_type) | The instance type for VECTR | `string` | `"t3a.large"` |
| <a name="input_vectr_release_sha256"></a> [vectr\_release\_sha256](#input\_vectr\_release\_sha256) | SHA-256 digest of the pinned VECTR runtime zip | `string` | `"8af50476d3c848d37489ab3a0edbe535c72b13f1c75cc96731db58976d9b0e22"` |
| <a name="input_vectr_sec_group"></a> [vectr\_sec\_group](#input\_vectr\_sec\_group) | The security group for the private VECTR instance | `string` | n/a |
| <a name="input_vectr_subnet"></a> [vectr\_subnet](#input\_vectr\_subnet) | The private subnet for the VECTR instance | `string` | n/a |
| <a name="input_vectr_version"></a> [vectr\_version](#input\_vectr\_version) | The pinned VECTR Community Edition release | `string` | `"9.14.1"` |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC where the private VECTR zone is associated | `string` | n/a |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Private Route 53 zone and VECTR hostname | `string` | `"thunderdome.lab"` |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_data_volume_id"></a> [data\_volume\_id](#output\_data\_volume\_id) | ID of the separate durable VECTR data volume, or null when disabled |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the private VECTR instance, or null when disabled |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address of VECTR, or null when disabled |
| <a name="output_url"></a> [url](#output\_url) | VECTR URL reachable through Client VPN, or null when disabled |
