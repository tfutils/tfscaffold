<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route_table_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | A list of availablity zones for subnets creation | `list(string)` | `[]` | no |
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_cidrs"></a> [cidrs](#input\_cidrs) | A list of CIDR blocks used for blue subnets creation - defines the total number to be created | `list(string)` | `[]` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Specify true to indicate that instances should be assigned a public IP address | `string` | `false` | no |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A list of route tables for subnets association. Specify one route table to be shared by all subnets or one route table for each subnet | `list(string)` | `[]` | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
<!-- END_TF_DOCS -->
