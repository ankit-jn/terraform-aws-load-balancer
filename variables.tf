variable "name" {
    description = "(Required) Name of the Load Balancer"
    type        = string
}

variable "internal" {
    description = "(Optional) Flag to decide if Load Balancer is internal or internet-facing"
    type        = bool
    default     = false
}

variable "lb_type" {
    description = "(Optional) The type of load balancer to create."
    type        = string
    default     = "application"

    validation {
        condition = (
            var.lb_type == "application" || 
            var.lb_type == "network" || 
            var.lb_type == "gateway")
        error_message = "Possible values for `lb_type` are `application`, `gateway` or `network`."
    }
}

variable "enable_access_logs" {
    description = "Flag to decide if Access Logs should be enabled"
    type        = bool
    default     = false
}

variable "access_logs" {
    description = <<EOF
Access Log Destinations Details

bucket: (Required) The S3 bucket name to store the logs in.
prefix: (Optional) The S3 bucket prefix. Logs are stored in the root if not configured.

EOF
    type = map(string)
    default =  {}
}

variable "subnets" {
    description = "A list of subnet IDs to attach to the LB"
    type = list(string)
    default =  []
}

variable "enable_deletion_protection" {
    description = "(Optional) Flag to decide if deletion of the load balancer will be disabled via the AWS API."
    type        = bool
    default     = false
}

variable "customer_owned_ipv4_pool" {
    description = "(Optional) The ID of the customer owned ipv4 pool to use for this load balancer."
    type        = string
    default     = null 
}

variable "ip_address_type" {
    description = "(Optional) The type of IP addresses used by the subnets for your load balancer"
    type        = string
    default     = "ipv4" 

    validation {
        condition = (
            var.ip_address_type == "ipv4" || 
            var.ip_address_type == "duakstack")
        error_message = "Possible values for `ip_address_type` are `ipv4` or `duakstack`."
    }
}

variable "desync_mitigation_mode" {
  description = <<EOF
(Optional) Determines how the load balancer handles requests that might pose a security risk 
to an application due to HTTP desync.
EOF
    type        = string
    default     = "defensive"

    validation {
        condition = (
            var.desync_mitigation_mode == "monitor" || 
            var.desync_mitigation_mode == "defensive" || 
            var.desync_mitigation_mode == "strictest")
        error_message = "Possible values for `desync_mitigation_mode` are `monitor`, `defensive` or `strictest`."
    }
}

variable "default_tags" {
  description = "(Optional) A map of tags to assign to all the resource."
  type        = map(any)
  default     = {}
}

######################################################
## Application Load Balancer Specific Properties
######################################################
variable "security_groups" {
    description = <<EOF
(Optional) A list of security group IDs to assign to the LB.

Note: Only Valid for ALB
EOF
    type = list(string)
    default = []
}

variable "create_sg" {
    description = <<EOF
Flag to decide if Security Group needs to be provisioned that will be assinged to Application Load Balancer

Note: Only Valid for ALB
EOF
    type        = bool
    default     = false
}

variable "vpc_id" {
  description = "The ID of VPC that is used for Security Group Provisioning"
  type        = string 
  default     = ""
}

variable "sg_name" {
    description = "(Optional) The name of the Security group"
    type        = string
    default     = ""
}

variable "sg_rules" {
    description = <<EOF

(Optional) Configuration List for Security Group Rules of Security Group:

It is a map of Rule Pairs where,
Key of the map is Rule Type and Value of the map would be an array of Security Rules Map 
There could be 2 Rule Types [Keys] : 'ingress', 'egress'

(Optional) Configuration List of Map for Security Group Rules where each entry will have following properties:

rule_name: (Required) The name of the Rule (Used for terraform perspective to maintain unicity)
description: (Optional) Description of the rule.
from_port: (Required) Start port (or ICMP type number if protocol is "icmp" or "icmpv6").
to_port: (Required) End port (or ICMP code if protocol is "icmp").
protocol: (Required) Protocol. If not icmp, icmpv6, tcp, udp, or all use the protocol number

self: (Optional) Whether the security group itself will be added as a source to this ingress rule. 
cidr_blocks: (Optional) List of IPv4 CIDR blocks
ipv6_cidr_blocks: (Optional) List of IPv6 CIDR blocks.
source_security_group_id: (Optional) Security group id to allow access to/from
 
Note: 
1. `cidr_blocks` Cannot be specified with `source_security_group_id` or `self`.
2. `ipv6_cidr_blocks` Cannot be specified with `source_security_group_id` or `self`.
3. `source_security_group_id` Cannot be specified with `cidr_blocks`, `ipv6_cidr_blocks` or `self`.
4. `self` Cannot be specified with `cidr_blocks`, `ipv6_cidr_blocks` or `source_security_group_id`.

Note: Only Valid for ALB

EOF
    default = {}
}

variable "drop_invalid_header_fields" {
  description = <<EOF
(Optional) Indicates whether HTTP headers with header fields that are not valid are 
removed by the load balancer (true) or routed to targets (false)

Note: Only Valid for ALB

  EOF
  type        = bool
  default     = false
}

variable "idle_timeout" {
    description = "(Optional) The time in seconds that the connection is allowed to be idle"
    type        = number
    default     = 60
}

variable "enable_http2" {
    description = "(Optional) Flag to decide if HTTP/2 is enabled in load balancers"
    type        = bool
    default     = true
}

variable "enable_waf_fail_open" {
  description = "Indicates whether to route requests to targets if lb fails to forward the request to AWS WAF"
  type        = bool
  default     = false
}


######################################################
## Network Load Balancer Specific Properties
######################################################
variable "enable_cross_zone_load_balancing" {
    description = "(Optional) Flag to decide if cross-zone load balancing of the load balancer will be enabled."
    type        = bool
    default     = false
}

variable "subnet_mappings" {
    description = <<EOF
List of the configurations of the Subnets which are being attached to Load Balancer 
where each entry will be a map corresponding to one subnet

subnet_id: (Required) ID of the subnet of which to attach to the load balancer
create_eip: (Optional, default false) Flag to decide if new Elastic IP address allocation is required
allocation_id: (Optional) The allocation ID of the Elastic IP address. It will be ignored if `create_eip` is set `true`
private_ipv4_address: (Optional) A private ipv4 address within the subnet to assign to the internal-facing load balancer. 
ipv6_address: (Optional) An ipv6 address within the subnet to assign to the internet-facing load balancer. 
EOF
    type = list(any)
    default = []
}

######################################################
## Target Groups
######################################################
variable "target_groups" {
    description = <<EOF
List of Target Groups for Load Balancer where each entry will be a map for Target Group Specification

name: (Required) Name of the target group.
target_type: (Optional, default `instance`) Type of target
port: (Required) Port on which targets receive traffic, unless overridden when registering a specific target.
protocol: (Optional, default `HTTP` if `target_type` is not `lambda`) Protocol to use to connect with the target.
protocol_version: (Optional) The protocol version. Only applicable when protocol is `HTTP` or `HTTPS`
EOF
    type = list(any)
    default = []
}