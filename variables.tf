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
## Application/Gateway Load Balancer Specific Properties
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
## Network/Gateway Load Balancer Specific Properties
######################################################
variable "enable_cross_zone_load_balancing" {
    description = "(Optional) Flag to decide if cross-zone load balancing of the load balancer will be enabled."
    type        = bool
    default     = false
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
connection_termination: (Optional, default `false`) Whether to terminate connections at the end of the deregistration timeout on Network Load Balancers.
deregistration_delay: (Optional, default `300`) Time, in seconds, for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused.
load_balancing_algorithm_type: (Optional, default `round_robin` if ALB) Determines how the Application Load balancer selects targets when routing requests.
lambda_multi_value_headers_enabled: (Optional) Whether the request and response headers exchanged between the load balancer and the Lambda function include arrays of values or strings.
preserve_client_ip: (Optional) Whether client IP preservation is enabled.
proxy_protocol_v2: (Optional, default `false` in NLB) Whether to enable support for proxy protocol v2 on Network Load Balancers.
slow_start: (Optional, default `0`) Time, in seconds for targets to warm up before the load balancer sends them a full share of requests.
health_check: Health Check configuration Map
    enabled: (Optional, default `true`) Whether health checks are enabled
    protocol: (Optional, default `HTTP` if target_type is not `lambda`) Protocol to use to connect with the target
    path: (Optional) Destination for the health check request.
    port: (Optional, default `traffic-port`) Port to use to connect with the target.
    interval: (Optional, default `30`) Approximate amount of time, in seconds, between health checks of an individual target.
    healthy_threshold: (Optional, default `3`) Number of consecutive health checks successes required before considering an unhealthy target healthy.
    unhealthy_threshold: (Optional, default `3`) Number of consecutive health check failures required before considering the target unhealthy.
    timeout: (Optional) Amount of time, in seconds, during which no response means a failed health check.
    matcher: (Optional) Response codes to use when checking for a healthy responses from a target.
stickiness: Stickiness configuration Map
    enabled: (Optional) Boolean to enable / disable stickiness
    type: (Required) The type of sticky sessions.
    cookie_name: (Optional) Name of the application based cookie.
    cookie_duration: (Optional) Only used when the type is lb_cookie. The time period, in seconds, during which requests from a client should be routed to the same target.
targets: List of Targets to be registered with the target Group where each entry will be a map of following keys,
    name: (required) Unique identifier within the list, for Terraform perspective
    target_id: (required) ID of the target to be registered; Instance ID, COntainer ID, or Lambda ARN, ARN of another ALB
    port: (Optional) Port on which target receives the traffic
    availability_zone: (Optional) The Availability Zone where the IP address of the target is to be registered.
EOF
    # type = list(any)
    default = []
}

variable "default_ssl_policy" {
    description = "The default SSL Policy for the listeners with Protocol `HTTPS` and `TLS`"
    type = string
    default = "ELBSecurityPolicy-2016-08"
}

variable "listeners" {
    description = <<EOF
Application/Network Load Balancer Listeners, where
MAP Key: Load Balancer Protocol [`HTTP`, `HTTPS`, `TCP`, `UDP`, `TCP_UDP`, `TLS`]
Map Value: List of Listeners where each entry of the list represent the listener configuration
    port: Port on which the load balancer is listening. 
    ssl_policy: (Optional) Name of the SSL Policy for the listener. Only for `HTTPS` and `TLS`
    certificate_arn: (Optional) ARN of the default SSL server certificate. Only for `HTTPS` and `TLS`
    alpn_policy: (Optional) Name of the Application-Layer Protocol Negotiation (ALPN) policy. Only for `TLS`
    action_type: (Optional, default `forward`) Type of Default routing action.
    forward: (Must define if `action_type` is not set or is set to `forward`) Forward Route Configurations
        target_groups: Map of 1-5 target group blocks
            name: (Required) Name of the target group.
            weight: (Optional) Weight. The range is 0 to 999.
        stickiness: (required only if need to enable stickiness) Time period, in seconds, during which requests from a client should be routed to the same target group.

    redirect: (Must define if `action_type` is set to `redirect`) Redirect Route Configurations
        status_code: (Required) HTTP redirect code.
        path: (Optional) Absolute path, starting with the leading "/".
        host: (Optional) Hostname.
        port: (Optional) Port.
        protocol: (Optional) Protocol.
        query: (Optional) Query parameters, URL-encoded when necessary, but not percent-encoded.
        
    fixed_response: (Must define if `action_type` is set to `fixed_response`) Fixed Response Route Configurations
        content_type: (Required) Content type
        message_body: (Optional) Message body.
        status_code: (Optional) HTTP response code. 

    authenticate_cognito: (Must define if `action_type` is set to `authenticate_cognito`) Cognito Authetication Route Configurations
        user_pool_arn: (Required) ARN of the Cognito user pool.
        user_pool_client_id: (Required) ID of the Cognito user pool client.
        user_pool_domain: (Required) Domain prefix or fully-qualified domain name of the Cognito user pool.
        authentication_request_extra_params: (Optional) Query parameters to include in the redirect request to the authorization endpoint.
        on_unauthenticated_request: (Optional) Behavior if the user is not authenticated.
        scope: (Optional) Set of user claims to be requested from the IdP.
        session_cookie_name: (Optional) Name of the cookie used to maintain session information.
        session_timeout: (Optional) Maximum duration of the authentication session, in seconds.

    authenticate_oidc: (Must define if `action_type` is set to `authenticate_oidc`) OIDC Authetication Route Configurations
        issuer: (Required) OIDC issuer identifier of the IdP.
        authorization_endpoint: (Required) Authorization endpoint of the IdP.
        client_id: (Required) OAuth 2.0 client identifier.
        client_secret: (Required) OAuth 2.0 client secret.
        token_endpoint: (Required) Token endpoint of the IdP.
        user_info_endpoint: (Required) User info endpoint of the IdP.
        authentication_request_extra_params: (Optional) Query parameters to include in the redirect request to the authorization endpoint.
        on_unauthenticated_request:  (Optional) Behavior if the user is not authenticated.
        scope: (Optional) Set of user claims to be requested from the IdP.
        session_cookie_name: (Optional) Name of the cookie used to maintain session information.
        session_timeout: (Optional) Maximum duration of the authentication session, in seconds.

    tags: (Optional) A map of tags to assign to the resource. 

EOF
    default     = {}
}

variable "gateway_listener" {
    description = "Listener Configuration for Gateway Load Balancer"
    type = map(string)
    default = {}
}

variable "listener_rules" {
    description = <<EOF
List of Application/Network Load Balancer Listener Rules where each entry will be a map:

listener_protocol: Listener Reference- The Load Balancer Protocol 
listener_port: Listener Reference- The Load Balancer Port
priority: Priority of Rule
actions: The Map of Routing Actions (at least one action is required): forward, redirect, fixed-response, authenticate_cognito, authenticate_oidc
         Structure is same as defined in property - `listeners` 
conditions: Map of following Conditions used with the Rule. At least one condition is required.
    host_header: (Optional) Contains a single values item which is a list of host header patterns to match
    http_header: (Optional) HTTP headers to match. Map of keys `header_name`, `header_values` 
        header_name: Header name
        header_values: List of values to match with
    http_request_method: (Optional) Contains a single values item which is a list of HTTP request methods or verbs to match.
    path_pattern: (Optional) Contains a single values item which is a list of path patterns to match against the request URL.
    query_string: (Optional) Query strings to match. List if Query string map
        key: Query String Key
        value: Query String Value
    source_ip: (Optional) Contains a single values item which is a list of source IP CIDR notations to match.

EOF
    default = []
}