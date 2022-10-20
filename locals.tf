locals {
        ## Create local variable to identify the Load Balancer Type
        alb = (var.lb_type == "application")
        nlb = (var.lb_type == "network")
        gateway = (var.lb_type == "gateway")

        security_groups = (local.alb && var.create_sg) ? [ module.security_group[0].security_group_id ] : var.security_groups
        
        ## Filter Ingress Rules
        sg_ingress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "ingress" ])
        ## Filter Egress Rules
        sg_egress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "egress" ])

        nlb_eips = { for subnet in var.subnet_mappings : subnet.subnet_id => subnet if lookup(subnet, "create_eip", false) }

        ## Enrich the targets with Target Type field and Target Group Name
        targets = merge(flatten([ for tg in var.target_groups: 
                                [ for target in lookup(tg, "targets", {}): 
                                        {format("%s.%s", tg.name, target.name) = merge(
                                                                                { "tg_name" = tg.name }, 
                                                                                { "tg_type" = tg.target_type },
                                                                                target)} ]])...)
        ## FIlter All Lamda Targets
        lambda_targets = { for k, target in local.targets:
                                k => merge(
                                        { "function_details" = split(":", target.target_id) }, 
                                        target) if target.tg_type == "lambda" }

        ## Load Balancer Plain Listeners (For `HTTP` if ALB, For `TCP`, `UDP` and `TCP_UDP` if NLB)
        listeners = merge(flatten([for protocol, value in var.listeners: 
                                        [ for listener in value: 
                                                {format("%s.%s", upper(protocol), listener.port) = merge(listener, 
                                                                                                         { "protocol" = upper(protocol) })} 
                                                        ] if contains([ "HTTP", "TCP", "UDP", "TCP_UDP", "HTTPS", "TLS" ], upper(protocol))])...)
                
        listener_rules = merge(flatten([for rule in var.listener_rules: 
                                        { format("%s.%s.%s", upper(rule.listener_protocol), rule.listener_port, rule.priority) = merge(
                                        {"listener" = format("%s.%s", upper(rule.listener_protocol), rule.listener_port)},
                                        rule)} ])...)
}