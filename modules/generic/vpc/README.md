<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.31.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >=2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_subnets_nat"></a> [subnets\_nat](#module\_subnets\_nat) | ../subnets | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.route53_resolver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat_nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_resolver_query_log_config.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config) | resource |
| [aws_route53_resolver_query_log_config_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config_association) | resource |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.dynamodb_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.dynamodb_private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.dynamodb_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.s3_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.s3_private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.s3_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_ipv4_cidr_block_association.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws"></a> [aws](#input\_aws) | n/a | <pre>object({<br/>    account_id   = string<br/>    default_tags = optional(map(string), {})<br/>    partition    = optional(string, "aws")<br/>    region       = string<br/>    url_suffix   = optional(string, "amazonaws.com")<br/>  })</pre> | n/a | yes |
| <a name="input_module_parents"></a> [module\_parents](#input\_module\_parents) | List of parent module names | `list(string)` | `[]` | no |
| <a name="input_nat"></a> [nat](#input\_nat) | The NAT Gateway configuration for the VPC<br/><br/>availability\_zones  = The list of availability zones to spread NAT subnets across - defaults to all available zones<br/>gateway\_count       = The number of NAT Gateways (and therefore NAT Gateway subnets) to create<br/>subnets\_netnum\_root = The first subnet network number with relation to the VPC CIDR block<br/>subnets\_newbits     = The number of bits to add to the subnet mask<br/><br/>Implemented using the terraform cidrsubnet function:<br/>https://developer.hashicorp.com/terraform/language/functions/cidrsubnet<br/><br/>[ for i in range(gateway\_count): cidrsubnet(var.vpc\_cidr, subnets\_newbits, subnets\_netnum\_root + i) ]<br/><br/>Example 1:<br/><br/>vpc\_cidr = "10.10.0.0/16", gateway\_count = 3, subnets\_netnum\_root = 4093, subnets\_newbits = 12<br/><br/>AZ1: 10.10.255.208/28<br/>AZ2: 10.10.255.224/28<br/>AZ3: 10.10.255.240/28<br/><br/>Example 2:<br/><br/>vpc\_cidr = "10.10.0.0/20", gateway\_count = 2, subnets\_netnum\_root = 0, subnets\_newbits = 4<br/><br/>AZ1: 10.10.0.0/24<br/>AZ2: 10.10.1.0/24 | <pre>object({<br/>    availability_zones   = optional(list(string), null)<br/>    gateway_count        = number<br/>    subnets_default_tags = optional(map(string), {})<br/><br/>    # NEVER set this to true.<br/>    # This is here only to allow for importing of legacy infrastucture<br/>    subnets_map_public_ip_on_launch = optional(bool, false)<br/><br/>    subnets_netnum_root = number<br/>    subnets_newbits     = number<br/>  })</pre> | `null` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | The root domain name assigned to the account | `string` | `null` | no |
| <a name="input_unique_ids"></a> [unique\_ids](#input\_unique\_ids) | n/a | <pre>object({<br/>    # All marked as optional for consistency of code.<br/>    # Whether each is optional depends on the module implementation.<br/>    local   = optional(string, null)<br/>    account = optional(string, null)<br/>    global  = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the base VPC | `string` | n/a | yes |
| <a name="input_vpc_secondary_cidrs"></a> [vpc\_secondary\_cidrs](#input\_vpc\_secondary\_cidrs) | Additional CIDR blocks for the base VPC (csv) (optional) | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | The Availability Zones |
| <a name="output_internet_gateway"></a> [internet\_gateway](#output\_internet\_gateway) | The Internet Gateway |
| <a name="output_nat"></a> [nat](#output\_nat) | NAT Gateway Configuration |
| <a name="output_route53_resolver_log_group"></a> [route53\_resolver\_log\_group](#output\_route53\_resolver\_log\_group) | The Route53 Resolver Log Group |
| <a name="output_route53_zone"></a> [route53\_zone](#output\_route53\_zone) | The Route53 Hosted Zone |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | The Route Tables |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The VPC |
| <a name="output_vpc_dhcp_options"></a> [vpc\_dhcp\_options](#output\_vpc\_dhcp\_options) | The VPC DHCP Options |
| <a name="output_vpc_gateway_endpoints"></a> [vpc\_gateway\_endpoints](#output\_vpc\_gateway\_endpoints) | The VPC Gateway Endpoints |
<!-- END_TF_DOCS -->