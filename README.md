# ARJ-Stack: AWS Load Balancer Terraform module

A Terraform module for configuring AWS Load Balancers

## Resources
This module features the following components to be provisioned with different combinations:

- Load Balancer [[aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)]
    - Application Load Balancer
    - Gateway Load Balancer
    - Network Load Balancer
- AWS Elastic IP Adddress [[aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)]
    - To be used by Subnet Mappings (Applicable in case NLB only)
- AWS Security Group [[aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)]
    - To be associated with Load Balancer (Applicable in case of ALB only)
- AWS Security Group Rules [[aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)]

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.22.0 |

## Examples

Refer [Configuration Examples](https://github.com/arjstack/terraform-aws-examples/tree/main/aws-load-balancer) for effectively utilizing this module.

## Inputs
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="name"></a> [name](#input\_name) | Name of the Load Balancer | `string` |  | yes | |
| <a name="internal"></a> [internal](#input\_internal) | Flag to decide if Load Balancer is internal or internet-facing | `bool` | `false` | no | |
| <a name="lb_type"></a> [lb_type](#input\_lb\_type) | The type of load balancer to create | `string` | `application` | no | |
| <a name="enable_access_logs"></a> [enable_access_logs](#input\_enable\_access\_logs) | Flag to decide if Access Logs should be enabled | `bool` | `false` | no | |
| <a name="access_logs"></a> [access_logs](#access\_logs) | Access Log Destinations Details | `map(string)` | `{}` | no | |
| <a name="subnets"></a> [subnets](#input\_subnets) | A list of subnet IDs to attach to the LB | `list(string)` | `[]` | no | |
| <a name="enable_deletion_protection"></a> [enable_deletion_protection](#input\_enable_deletion_protection) | Flag to decide if deletion of the load balancer will be disabled via the AWS API | `bool` | `false` | no | |
| <a name="customer_owned_ipv4_pool"></a> [customer_owned_ipv4_pool](#input\_customer\_owned\_ipv4\_pool) | The ID of the customer owned ipv4 pool to use for this load balancer | `string` |  | no | |
| <a name="ip_address_type"></a> [ip_address_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer | `string` | `ipv4` | no | |
| <a name="desync_mitigation_mode"></a> [desync_mitigation_mode](#input\_desync\_mitigation\_mode) | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. | `string` | `defensive` | no | |
| <a name="default_tags"></a> [default_tags](#input\_default\_tags) | A map of tags to assign to all the resource | `map` | `{}` | no | |

#### Application/Gateway Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="security_groups"></a> [security_groups](#input\_security\_groups) | A list of security group IDs to assign to the LB | `list(string)` | `[]` | no | |
| <a name="create_sg"></a> [create_sg](#input\_create\_sg) | Flag to decide if Security Group needs to be provisioned that will be assinged to Application Load Balancer | `bool` | `false` | no | |
| <a name="vpc_id"></a> [vpc_id](#input\_vpc\_id) | The ID of VPC that is used for Security Group Provisioning | `string` |  | no | |
| <a name="sg_name"></a> [sg_name](#input\_sg\_name) | The name of the Security group | `string` | `<ALB Name>-sg` | no | |
| <a name="sg_rules"></a> [sg_rules](#sg\_rules) | Configuration List for Security Group Rules of Security Group | `map` | `{}` | no | <pre>{<br>   ingress = [<br>      {<br>        rule_name = "Self Ingress Rule"<br>        description = "Self Ingress Rule"<br>        from_port =0<br>        to_port = 0<br>        protocol = "-1"<br>        self = true<br>      },<br>      {<br>        rule_name = "Ingress from IPv4 CIDR"<br>        description = "IPv4 Rule"<br>        from_port = 443<br>        to_port = 443<br>        protocol = "tcp"<br>        cidr_blocks = ["xx.xx.xx.xx/xx", "yy.yy.yy.yy/yy"]<br>      }<br>   ]<br>   egress =[<br>      {<br>        rule_name = "Self Egress Rule"<br>        description = "Self Egress Rule"<br>        from_port =0<br>        to_port = 0<br>        protocol = "-1"<br>        self = true<br>      }<br>   ]<br>} |
| <a name="drop_invalid_header_fields"></a> [drop_invalid_header_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false) | `bool` | `false` | no | |
| <a name="idle_timeout"></a> [idle_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle | `number` | `60` | no | |
| <a name="enable_http2"></a> [enable_http2](#input\_enable\_http2) | Flag to decide if HTTP/2 is enabled in load balancers | `bool` | `true` | no | |
| <a name="enable_waf_fail_open"></a> [enable_waf_fail_open](#input\_enable\_waf\_fail\_open) | Indicates whether to route requests to targets if lb fails to forward the request to AWS WAF | `bool` | `false` | no | |

#### Network Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="subnet_mappings"></a> [subnet_mappings](#subnet\_mappings) | List of the configurations of the Subnets which are being attached to Load Balancer. <br> This property will take preference over the property `subnets`  | `list` | `[]` | no | |

#### Network/Gateway Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="enable_cross_zone_load_balancing"></a> [enable_cross_zone_load_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Flag to decide if cross-zone load balancing of the load balancer will be enabled | `bool` | `false` | no | |

## Nested Configuration Maps:  

#### access_logs
| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="bucket"></a> [bucket](#input\_bucket) | The S3 bucket name to store the logs in | `string` |  | yes | |
| <a name="prefix"></a> [prefix](#input\_prefix) | The S3 bucket prefix. Logs are stored in the root if not configured. | `string` |  | no | |

#### subnet_mappings
| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="subnet_id"></a> [subnet_id](#input\_subnet\_id) | ID of the subnet of which to attach to the load balancer | `string` |  | yes | |
| <a name="create_eip"></a> [create_eip](#input\_create\_eip) | Flag to decide if new Elastic IP address allocation is required | `bool` | `false` | no | |
| <a name="allocation_id"></a> [allocation_id](#input\_allocation\_id) | The allocation ID of the Elastic IP address. It will be ignored if `create_eip` is set `true` | `string` |  | no | |
| <a name="private_ipv4_address"></a> [private_ipv4_address](#input\_private\_ipv4\_address) | A private ipv4 address within the subnet to assign to the internal-facing load balancer.  | `string` |  | no | |
| <a name="ipv6_address"></a> [ipv6_address](#input\_ipv6\_address) | An ipv6 address within the subnet to assign to the internet-facing load balancer.  | `string` |  | no | |

#### sg_rules [ Ingress / Egress ]

- `cidr_blocks` Cannot be specified with `source_security_group_id` or `self`.
- `ipv6_cidr_blocks` Cannot be specified with `source_security_group_id` or `self`.
- `source_security_group_id` Cannot be specified with `cidr_blocks`, `ipv6_cidr_blocks` or `self`.
- `self` Cannot be specified with `cidr_blocks`, `ipv6_cidr_blocks` or `source_security_group_id`.

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="rule_name"></a> [rule_name](#input\_rule\_name) | The name of the Rule (Used for terraform perspective to maintain unicity) | `string` |  | yes | |
| <a name="description"></a> [description](#input\_description) | Description of the rule. | `string` |  | yes | |
| <a name="from_port"></a> [from_port](#input\_from\_port) | Start port (or ICMP type number if protocol is "icmp" or "icmpv6"). | `number` |  | yes | |
| <a name="to_port"></a> [to_port](#input\_to\_port) | End port (or ICMP code if protocol is "icmp"). | `number` |  | yes | |
| <a name="protocol"></a> [protocol](#input\_protocol) | Protocol. If not icmp, icmpv6, tcp, udp, or all use the protocol number | `string | number` |  | yes | |
| <a name="self"></a> [self](#input\_self) | Whether the security group itself will be added as a source to this ingress rule.  | `bool` |  | no | |
| <a name="cidr_blocks"></a> [cidr_blocks](#input\_cidr\_blocks) | List of IPv4 CIDR blocks | `list(string)` |  | no | |
| <a name="ipv6_cidr_blocks"></a> [ipv6_cidr_blocks](#input\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks. | `list(string)` |  | no | |
| <a name="source_security_group_id"></a> [source_security_group_id](#input\_source\_security\_group\_id) | Security group id to allow access to/from | `string` |  | no | |

## Outputs

| Name | Type | Description |
|:------|:------|:------|
| <a name="arn"></a> [arn](#output\_arn) | `string` | The ARN of the load balancer |
| <a name="dns_name"></a> [dns_name](#output\_dns\_name) | `string` | The DNS name of the load balancer |
| <a name="zone_id"></a> [zone_id](#output\_zone\_id) | `string` | The canonical hosted zone ID of the load balancer |
| <a name="sg_id"></a> [sg_id](#output\_sg\_id) | `string` | The Security Group ID associated to ALB |

## Authors

Module is maintained by [Ankit Jain](https://github.com/ankit-jn) with help from [these professional](https://github.com/arjstack/terraform-aws-iam/graphs/contributors).

