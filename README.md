## ARJ-Stack: AWS Load Balancer Terraform module

A Terraform module for configuring AWS Load Balancers

### Resources
This module features the following components to be provisioned with different combinations:

- Load Balancer [[aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)]
    - Application Load Balancer
    - Network Load Balancer
    - Gateway Load Balancer
- AWS Elastic IP Adddress [[aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)]
    - To be used by Subnet Mappings (Applicable in case NLB only)
- Target Group [[aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)]
- Target Registration [[aws_lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment)]
- Lambda Permission [[aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)]
- Load Balancer Listener [[aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)]
- Load Balancer Listener Rule [[aws_lb_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule)]
- Security Group [[aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)]
    - To be associated with Load Balancer (Applicable in case of ALB only)
- Security Group Rules [[aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)]

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.22.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.22.0 |

### Examples

Refer [Configuration Examples](https://github.com/arjstack/terraform-aws-examples/tree/main/aws-load-balancer) for effectively utilizing this module.

### Inputs
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
| <a name="target_groups"></a> [target_groups](#target\_group) | List of Target Groups for Load Balancer | `list(any)` | `[]` | no | <pre>[<br>   {<br>     name = "alb-target-1"<br>     target_type  = "ip"<br>     port = 80<br>     protocol = "HTTP"<br>     interval = 60<br><br>     health_check = {<br>         healthy_threshold = 5<br>         unhealthy_threshold = 3<br>     }<br>     stickiness = {<br>       type = "lb_cookie"<br>       cookie_duration = 3600<br>     }<br>   }<br>] |
| <a name="default_ssl_policy"></a> [default_ssl_policy](#input\_default\_ssl\_policy) | The default SSL Policy for the listeners with Protocol `HTTPS` and `TLS` | `string` | `"ELBSecurityPolicy-2016-08"` | no | |
| <a name="listeners"></a> [listeners](#listener) | Map of Application/Network Load Balancer Listeners where Map Keys are the LB protocols: `HTTP`, `HTTPS`, `TCP`, `UDP`, `TCP_UDP`, `TLS` and values are the list of Listeners for keyed protocol. Only applicable for ALB, NLB | `map` | `{}` | no | <pre>{<br>   http = [<br>     {<br>       port = 80<br>       order = 3000<br>       forward = {<br>         target_groups = {<br>           "alb-target-8080" = {<br>             weight = 70<br>           }<br>           "alb-target-8081" = {<br>             weight = 30<br>           }<br>         }<br>         stickiness = 60<br>       }<br>     },<br>     {<br>       port = 81<br>       order = 3000<br>       action_type = "redirect"<br>       redirect = {<br>         port        = "8081"<br>         protocol    = "HTTP"<br>         status_code = "HTTP_301"<br>       }<br>     },<br>   ],<br>   https = [<br>     {<br>       port = 443<br>       action_type = "authenticate-cognito"<br>       order = 3000<br>       certificate_arn = "arn:aws:acm:<region>::certificate/<certificate_ID>"<br>       authenticate_cognito = {<br>         user_pool_arn       = "arn:aws:cognito-idp:<region>::userpool/<pool_id>"<br>         user_pool_client_id = "client id"<br>         user_pool_domain    = "domain"<br>       }<br>     }<br>   ]<br>} |
| <a name="gateway_listener"></a> [gateway_listener](#input\_gateway_listener) | Listener Configuration for Gateway Load Balancer | `map(string)` | `{}` | no | <pre>{<br>   target_group = "Default Target Group Name for Gateway LB"<br>} |
| <a name="listener_rules"></a> [listener_rules](#listener_rule) | List of Application/Network Load Balancer Listener Rules | `list` | `[]` | no | <pre>[<br>   {<br>     listener_protocol = "HTTP"<br>     listener_port = 80<br>     priority = 200<br><br>     actions = {<br>       forward = {<br>         target_group = "target group name"<br>       },<br>       redirect = {<br>         // redirect action properties<br>       }<br>     }<br>     conditions = {<br>       path_pattern =[<br>         "/images",<br>         "static"<br>       ]<br>       source_ip = ["xxx.xxx.xxx.xxx/xx"]<br>     }<br>   },<br>   {<br>     listener_protocol = "HTTP"<br>     listener_port = 81<br>     priority = 300<br><br>     actions = {<br>       weighted_forward = {<br>         target_groups = {<br>           // define at least 2 target maps with weight<br>         }<br>       },<br>       fixed_response = {<br>         // fixed-response action properties<br>       }<br>     }<br>     conditions = {<br>       values for one of the conditions<br>       host_header = [<br>         "arjstack.com",<br>         "google.com"<br>       ]<br>     }<br>   }<br>] |
| <a name="default_tags"></a> [default_tags](#input\_default\_tags) | A map of tags to assign to all the resource | `map` | `{}` | no | |


#### Application/Gateway Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="security_groups"></a> [security_groups](#input\_security\_groups) | A list of security group IDs to assign to the LB | `list(string)` | `[]` | no | |
| <a name="create_sg"></a> [create_sg](#input\_create\_sg) | Flag to decide if Security Group needs to be provisioned that will be assinged to Application Load Balancer | `bool` | `false` | no | |
| <a name="vpc_id"></a> [vpc_id](#input\_vpc\_id) | The ID of VPC; <br>- Required while SG provisioning for ALB<br>- Required while provisiong target group with `ip` or `instance` | `string` |  | no | |
| <a name="sg_name"></a> [sg_name](#input\_sg\_name) | The name of the Security group | `string` | `<ALB Name>-sg` | no | |
| <a name="sg_rules"></a> [sg_rules](#sg\_rules) | Configuration List for Security Group Rules of Security Group | `map` | `{}` | no | <pre>{<br>   ingress = [<br>      {<br>        rule_name = "Self Ingress Rule"<br>        description = "Self Ingress Rule"<br>        from_port =0<br>        to_port = 0<br>        protocol = "-1"<br>        self = true<br>      },<br>      {<br>        rule_name = "Ingress from IPv4 CIDR"<br>        description = "IPv4 Rule"<br>        from_port = 443<br>        to_port = 443<br>        protocol = "tcp"<br>        cidr_blocks = ["xx.xx.xx.xx/xx"]<br>      }<br>   ]<br>   egress =[<br>      {<br>        rule_name = "Self Egress Rule"<br>        description = "Self Egress Rule"<br>        from_port =0<br>        to_port = 0<br>        protocol = "-1"<br>        self = true<br>      }<br>   ]<br>} |
| <a name="drop_invalid_header_fields"></a> [drop_invalid_header_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false) | `bool` | `false` | no | |
| <a name="idle_timeout"></a> [idle_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle | `number` | `60` | no | |
| <a name="enable_http2"></a> [enable_http2](#input\_enable\_http2) | Flag to decide if HTTP/2 is enabled in load balancers | `bool` | `true` | no | |
| <a name="enable_waf_fail_open"></a> [enable_waf_fail_open](#input\_enable\_waf\_fail\_open) | Indicates whether to route requests to targets if lb fails to forward the request to AWS WAF | `bool` | `false` | no | |

#### Network Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="subnet_mappings"></a> [subnet_mappings](#subnet\_mappings) | List of the configurations of the Subnets which are being attached to Load Balancer. <br> This property will take preference over the property `subnets`  | `list(any)` | `[]` | no | <pre>[<br>   {<br>     subnet_id = "subnet-1xxxxxx......."<br>     create_eip = true<br>   },<br>   {<br>     subnet_id = "subnet-2xxxx........."<br>     allocation_id = "Allocation ID"<br>     ## it will be skipped simply<br>     ## as LB is internet facing<br>     private_ipv4_address = "<Private IP from this subnet>"<br>   },<br>] |

#### Network/Gateway Load Balancer Specific Properties
---

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="enable_cross_zone_load_balancing"></a> [enable_cross_zone_load_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Flag to decide if cross-zone load balancing of the load balancer will be enabled | `bool` | `false` | no |

### Nested Configuration Maps:  

#### access_logs
| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="bucket"></a> [bucket](#input\_bucket) | The S3 bucket name to store the logs in | `string` |  | yes |
| <a name="prefix"></a> [prefix](#input\_prefix) | The S3 bucket prefix. Logs are stored in the root if not configured. | `string` |  | no |

#### subnet_mappings
| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="subnet_id"></a> [subnet_id](#input\_subnet\_id) | ID of the subnet of which to attach to the load balancer | `string` |  | yes |
| <a name="create_eip"></a> [create_eip](#input\_create\_eip) | Flag to decide if new Elastic IP address allocation is required | `bool` | `false` | no |
| <a name="allocation_id"></a> [allocation_id](#input\_allocation\_id) | The allocation ID of the Elastic IP address. It will be ignored if `create_eip` is set `true` | `string` |  | no |
| <a name="private_ipv4_address"></a> [private_ipv4_address](#input\_private\_ipv4\_address) | A private ipv4 address within the subnet to assign to the internal-facing load balancer.  | `string` |  | no |
| <a name="ipv6_address"></a> [ipv6_address](#input\_ipv6\_address) | An ipv6 address within the subnet to assign to the internet-facing load balancer.  | `string` |  | no |

#### sg_rules
[ Ingress / Egress ]

- Map of Security Group Rules with 2 Keys `ingress` and `egress`.
- The value for each key will be a list of Security group rules where each entry of the list will again be a map of SG Rule Configuration

Refer [SG Rules Configuration](https://github.com/arjstack/terraform-aws-security-groups/blob/v1.0.0/README.md#security-group-rule--ingress--egress-) for the structure

#### target_group

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="name"></a> [name](#input\_name) | Name of the target group | `string` |  | yes | |
| <a name="target_type"></a> [target_type](#input\_target\_type) | Type of target<br>- NLB do not support the `lambda` target type.<br>- ALB do not support the `alb` target type. | `string` | `"instance"` | no | |
| <a name="port"></a> [port](#input\_port) | Port on which targets receive traffic, unless overridden when registering a specific target.<br> Set as `6081` as default for GatewayLoad Balancer. | `number` |  | no | |
| <a name="protocol"></a> [protocol](#input\_protocol) | Protocol to use to connect with the target.<br>- Set as `GENEVE` as default for GatewayLoad Balancer.<br>- Not required in `target_type` is `lambda` | `string` |  | no | |
| <a name="protocol_version"></a> [protocol_version](#input\_protocol\_version) | The protocol version. Only applicable when `protocol` is `HTTP` or `HTTPS` | `string` |  | no | |
| <a name="connection_termination"></a> [connection_termination](#input\_connection\_termination) | Whether to terminate connections at the end of the deregistration timeout on Load Balancers. Only applicable with NLB. | `bool` | `false` | no | |
| <a name="deregistration_delay"></a> [deregistration_delay](#input\_deregistration\_delay) | Time, in seconds, for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. | `number` | `300` | no | |
| <a name="load_balancing_algorithm_type"></a> [load_balancing_algorithm_type](#input\_load\_balancing\_algorithm\_type) | Determines how the Load balancer selects targets when routing requests. Only applicable with ALB. | `string` | `round_robin` | no | |
| <a name="lambda_multi_value_headers_enabled"></a> [lambda_multi_value_headers_enabled](#input\_lambda\_multi\_value\_headers\_enabled) | Whether the request and response headers exchanged between the load balancer and the Lambda function include arrays of values or strings. Only applicable with `target_type` as `lambda`. | `bool` | `false` | no | |
| <a name="preserve_client_ip"></a> [preserve_client_ip](#input\_preserve\_client\_ip) | Whether client IP preservation is enabled. | `bool` |  | no | |
| <a name="proxy_protocol_v2"></a> [proxy_protocol_v2](#input\_proxy\_protocol\_v2) | Whether to enable support for proxy protocol v2 on Load Balancers. Only applicable with NLB. | `bool` | `false` | no | |
| <a name="slow_start"></a> [slow_start](#input\_slow\_start) | Time, in seconds, for targets to warm up before the load balancer sends them a full share of requests. | `number` | `0` | no | |
| <a name="health_check"></a> [health_check](#health\_check) | Health Check configuration | `map(any)` |  | no | |
| <a name="stickiness"></a> [stickiness](#stickiness) | Stickiness configuration | `map(any)` |  | no | |
| <a name="targets"></a> [targets](#targets) | List of Targets to be registered with the target Group | `list(any)` |  | no | <pre>[<br>   {<br>     name        = "target-1"<br>     target_id   = "<EC2 Instance#1 ID>"<br>     port        = 80<br>   },<br>   {<br>     name        = "target-2"<br>     target_id   = "<EC2 Instance#2 ID>"<br>     port        = 8080<br>   }<br>] |

#### health_check

- At least one property needs to be defined

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="enabled"></a> [enabled](#input\_enabled) | Whether health checks are enabled | `bool` | `true` | no |
| <a name="protocol"></a> [protocol](#input\_protocol) | Protocol to use to connect with the target. It is not required in `target_type` is `lambda` | `string` | `"HTTP"` | no |
| <a name="path"></a> [path](#input\_path) | Destination for the health check request. | `string` |  | no |
| <a name="port"></a> [port](#input\_port) | Port to use to connect with the target. | `string` | `"traffic-port"` | no |
| <a name="interval"></a> [interval](#input\_interval) | Approximate amount of time, in seconds, between health checks of an individual target. | `number` | `30` | no |
| <a name="healthy_threshold"></a> [healthy_threshold](#input\_healthy\_threshold) | Number of consecutive health checks successes required before considering an unhealthy target healthy. | `number` | `3` | no |
| <a name="unhealthy_threshold"></a> [unhealthy_threshold](#input\_unhealthy\_threshold) | Number of consecutive health check failures required before considering the target unhealthy.<br>It should be the same as `healthy_threshold` if it is NLB. | `number` | `3` | no |
| <a name="timeout"></a> [timeout](#input\_timeout) | Amount of time, in seconds, during which no response means a failed health check. | `number` |  | no |
| <a name="matcher"></a> [matcher](#input\_matcher) | Response codes to use when checking for a healthy responses from a target. Only applicable with ALB. | `string` |  | no |

#### stickiness

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="enabled"></a> [enabled](#input\_enabled) | Boolean to enable / disable stickiness | `bool` | `true` | no |
| <a name="type"></a> [type](#input\_type) | The type of sticky sessions. | `string` |  | yes |
| <a name="cookie_name"></a> [cookie_name](#input\_cookie_name) | Name of the application based cookie. Only Valid if stickiness `type` is `app_cookie` | `string` |  | no |
| <a name="cookie_duration"></a> [cookie_duration](#input\_cookie_duration) | The time period, in seconds, during which requests from a client should be routed to the same target. Only Valid if stickiness `type` is `lb_cookie` | `number` |  | no |

#### targets

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="name"></a> [name](#input\_name) | Unique identifier within the list, for Terraform perspective | `string` |  | yes |
| <a name="target_id"></a> [target_id](#input\_target_id) | ID of the target to be registered; Instance ID, COntainer ID, or Lambda ARN, ARN of another ALB | `string` |  | yes |
| <a name="port"></a> [port](#input\_port) | Port on which target receives the traffic | `string` |  | no |
| <a name="availability_zone"></a> [availability_zone](#input\_availability\_zone) | The Availability Zone where the IP address of the target is to be registered. | `string` |  | no |

#### listener

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="port"></a> [port](#input\_port) | Port on which the load balancer is listening.  | `number` |  | yes | |
| <a name="ssl_policy"></a> [ssl_policy](#input\_ssl\_policy) | Name of the SSL Policy for the listener. Only for `HTTPS` and `TLS` | `string` |  | no | |
| <a name="certificate_domain"></a> [certificate_domain](#input\_certificate\_domain) | Fully Qualified domain for which Certificate status in ACM is `ISSUED`. Only for `HTTPS` and `TLS` | `string` |  | no | |
| <a name="certificate_arn"></a> [certificate_arn](#input\_certificate\_arn) | ARN of the default SSL server certificate. <br>Only for `HTTPS` and `TLS`<br>This property will take preference over `certificate_domain` | `string` |  | no | |
| <a name="alpn_policy"></a> [alpn_policy](#input\_alpn\_policy) | Name of the Application-Layer Protocol Negotiation (ALPN) policy. Only for `TLS` | `string` |  | no | |
| <a name="action_type"></a> [action_type](#input\_action\_type) | Type of Default routing action | `string` | `"forward"` | no | |
| <a name="forward"></a> [forward](#action\_forward) | Forward Route Configurations.<br>(Must define if `action_type` is not set or is set to `forward`) | `map(any)` |  | no | <pre>{<br>   target_groups = {<br>     "alb-target-8080" = {<br>       weight = 70<br>     }<br>     "alb-target-8081" = {<br>       weight = 30<br>     }<br>   }<br>   stickiness = 60<br>} |
| <a name="redirect"></a> [redirect](#action\_redirect) | Redirect Route Configurations.<br>(Must define if `action_type` is set to `redirect`) | `map(any)` |  | no | <pre>{<br>   port        = "8081"<br>   protocol    = "HTTP"<br>   status_code = "HTTP_301"<br>} |
| <a name="fixed_response"></a> [fixed_response](#action\_fixed\_response) | Fixed Response Route Configurations.<br>(Must define if `action_type` is set to `fixed_response`) | `map(any)` |  | no | <pre>{<br>   content_type = "text/plain"<br>   message_body = "Fixed message"<br>   status_code = "200"<br>} |
| <a name="authenticate_cognito"></a> [authenticate_cognito](#action\_authenticate\_cognito) | Cognito Authetication Route Configurations.<br>(Must define if `action_type` is set to `authenticate_cognito`) | `map(any)` |  | no | |
| <a name="authenticate_oidc"></a> [authenticate_oidc](#action\_authenticate\_oidc) | OIDC Authetication Route Configurations.<br>(Must define if `action_type` is set to `authenticate_oidc`) | `map(any)` |  | no | |

#### action_forward

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="target_groups"></a> [target_groups](#input\_target\_groups) | Map of 1-5 target group blocks | `map(any)` |  | no | <pre>{<br>   "alb-target-8080" = {<br>     weight = 70<br>   }<br>   "alb-target-8081" = {<br>     weight = 30<br>   }<br>} |
| <a name="stickiness"></a> [stickiness](#input\_stickiness) | Time period, in seconds, during which requests from a client should be routed to the same target group. | `number` |  | no | |

#### action_redirect

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="status_code"></a> [status_code](#input\_status\_code) | HTTP redirect code. Either `HTTP_301` or `HTTP_302` | `string` |  | yes |
| <a name="path"></a> [path](#input\_path) | Absolute path, starting with the leading "/". | `string` | `"/#{path}"` | no |
| <a name="host"></a> [host](#input\_host) | Hostname | `string` | `"#{host}"` | no |
| <a name="port"></a> [port](#input\_port) | Port | `number` | `"#{port}"` | no |
| <a name="protocol"></a> [protocol](#input\_protocol) | Protocol | `string` | `"#{protocol}"` | no |
| <a name="query"></a> [query](#input\_query) | Query parameters, URL-encoded when necessary, but not percent-encoded. | `string` | `"#{query}"` | no |

#### action_fixed_response

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="content_type"></a> [content_type](#input\_content\_type) | Content type | `string` |  | yes |
| <a name="message_body"></a> [message_body](#input\_message\_body) | Message body | `string` |  | no |
| <a name="status_code"></a> [status_code](#input\_status\_code) | HTTP response code | `string` |  | no |

#### action_authenticate_cognito

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="user_pool_arn"></a> [user_pool_arn](#input\_user\_pool\_arn) | ARN of the Cognito user pool | `string` |  | yes |
| <a name="user_pool_client_id"></a> [user_pool_client_id](#input\_user\_pool\_client\_id) | ID of the Cognito user pool client. | `string` |  | yes |
| <a name="user_pool_domain"></a> [user_pool_domain](#input\_user\_pool\_domain) | Domain prefix or fully-qualified domain name of the Cognito user pool. | `string` |  | yes |
| <a name="authentication_request_extra_params"></a> [authentication_request_extra_params](#input\_authentication\_request\_extra\_params) | Query parameters to include in the redirect request to the authorization endpoint. | `map(string)` |  | no |
| <a name="on_unauthenticated_request"></a> [on_unauthenticated_request](#input\_on\_unauthenticated\_request) | Behavior if the user is not authenticated. | `string` |  | no |
| <a name="scope"></a> [scope](#input\_scope) | Set of user claims to be requested from the IdP. | `set(string)` |  | no |
| <a name="session_cookie_name"></a> [session_cookie_name](#input\_session\_cookie\_name) | Name of the cookie used to maintain session information. | `string` |  | no |
| <a name="session_timeout"></a> [session_timeout](#input\_session\_timeout) | Maximum duration of the authentication session, in seconds. | `number` |  | no |

#### action_authenticate_oidc

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="issuer"></a> [issuer](#input\_issuer) | OIDC issuer identifier of the IdP. | `string` |  | yes |
| <a name="authorization_endpoint"></a> [authorization_endpoint](#input\_authorization\_endpoint) | Authorization endpoint of the IdP. | `string` |  | yes |
| <a name="client_id"></a> [client_id](#input\_client\_id) | OAuth 2.0 client identifier | `string` |  | yes |
| <a name="client_secret"></a> [client_secret](#input\_client\_secret) | OAuth 2.0 client secret | `string` |  | yes |
| <a name="token_endpoint"></a> [token_endpoint](#input\_token\_endpoint) | Token endpoint of the IdP | `string` |  | yes |
| <a name="user_info_endpoint"></a> [user_info_endpoint](#input\_user\_info\_endpoint) | User info endpoint of the IdP | `string` |  | yes |
| <a name="authentication_request_extra_params"></a> [authentication_request_extra_params](#input\_authentication\_request\_extra\_params) | Query parameters to include in the redirect request to the authorization endpoint. | `map(string)` |  | no |
| <a name="on_unauthenticated_request"></a> [on_unauthenticated_request](#input\_on\_unauthenticated\_request) | Behavior if the user is not authenticated. | `string` |  | no |
| <a name="scope"></a> [scope](#input\_scope) | Set of user claims to be requested from the IdP | `set(string)` |  | no |
| <a name="session_cookie_name"></a> [session_cookie_name](#input\_session\_cookie\_name) | Name of the cookie used to maintain session information. | `string` |  | no |
| <a name="session_timeout"></a> [session_timeout](#input\_session\_timeout) | Maximum duration of the authentication session, in seconds. | `number` |  | no |

#### listener_rule

| Name | Description | Type | Default | Required |
|:------|:------|:------|:------|:------:|
| <a name="listener_protocol"></a> [listener_protocol](#input\_listener\_protocol) | Listener Reference- The Load Balancer Protocol  | `string` |  | yes |
| <a name="listener_port"></a> [listener_port](#input\_listener\_port) | Listener Reference- The Load Balancer Port | `number` |  | yes |
| <a name="priority"></a> [priority](#input\_priority) | Priority of Rule | `number` |  | yes |
| <a name="actions"></a> [actions](#input\_actions) | The Map of Routing Actions (at least one action is required):<br>`forward`: It is a map with single property `target_group`<br>[`weighted_forward`](#action_forward)<br>[`redirect`](#action_redirect)<br>[`fixed-response`](#action_fixed_response)<br>[`authenticate_cognito`](#action_authenticate_cognito)<br>[`authenticate_oidc`](#action_authenticate_oidc) | `string` |  | yes |
| <a name="conditions"></a> [conditions](#conditions) | Map of Conditions used with the Rule: At least one condition is required. | `map` |  | yes |

#### conditions

| Name | Description | Type | Default | Required | Example|
|:------|:------|:------|:------|:------:|:------|
| <a name="host_header"></a> [host_header](#input\_host\_header) | Contains a single values item which is a list of host header patterns to match | `list(string)` |  | yes | <pre>[<br>   "arjstack.com",<br>   "google.com"<br>] |
| <a name="http_header"></a> [http_header](#input\_http\_header) | HTTP headers to match. | `map` |  | yes | <pre>{<br>   header_name = "x-amz-security-token"<br>   header_values = ["v1", "v2"]<br>}|
| <a name="http_request_method"></a> [http_request_method](#input\_http\_request\_method) | Contains a single values item which is a list of HTTP request methods or verbs to match. | `list(string)` |  | yes | <pre>[<br>   "PUT",<br>   "POST"<br>] |
| <a name="path_pattern"></a> [path_pattern](#input\_path\_pattern) | Contains a single values item which is a list of path patterns to match against the request URL. | `list(string)` |  | yes | <pre>[<br>   "/images",<br>   "/static"<br>] |
| <a name="query_string"></a> [query_string](#input\_query\_string) | Query strings (key-value pair) to match | `list` |  | yes | <pre>[<br>   {<br>     key = "type"<br>     value = "images"<br>   },<br>   {<br>     key = "location"<br>     value = "asia"<br>   },<br>] |
| <a name="source_ip"></a> [source_ip](#input\_source_ip) | Contains a single values item which is a list of source IP CIDR notations to match. | `list(string)` |  | no | <pre>[<br>   "xxx.xxx.xxx.xxx/xx",<br>   "xxx.xxx.xxx.xxx/xx"<br>] |

### Outputs

| Name | Type | Description |
|:------|:------|:------|
| <a name="arn"></a> [arn](#output\_arn) | `string` | The ARN of the load balancer |
| <a name="dns_name"></a> [dns_name](#output\_dns\_name) | `string` | The DNS name of the load balancer |
| <a name="zone_id"></a> [zone_id](#output\_zone\_id) | `string` | The canonical hosted zone ID of the load balancer |
| <a name="sg_id"></a> [sg_id](#output\_sg\_id) | `string` | The Security Group ID associated to ALB |
| <a name="target_groups"></a> [target_groups](#output\_target\_groups) | `map(string)` | The target Groups' ARN |
| <a name="listeners"></a> [listeners](#output\_listeners) | `map(string)` | The Listeners' ARN for ALB/NLB |
| <a name="gateway_listener"></a> [gateway_listener](#output\_gateway\_listener) | `string` | Listener ARN for Gateway Load Balancer |

### Authors

Module is maintained by [Ankit Jain](https://github.com/ankit-jn) with help from [these professional](https://github.com/arjstack/terraform-aws-load-balancer/graphs/contributors).

