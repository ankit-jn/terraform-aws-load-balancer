locals {
    
    alb = (var.lb_type == "application")
    nlb = (var.lb_type == "network")
    gateway = (var.lb_type == "gateway")

    security_groups = (local.alb && var.create_sg) ? [ module.security_group[0].security_group_id ] : var.security_groups
    sg_ingress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "ingress" ])
    sg_egress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "egress" ])

    nlb_eips = { for subnet in var.subnet_mappings : subnet.subnet_id => subnet if lookup(subnet, "create_eip", false) }
}