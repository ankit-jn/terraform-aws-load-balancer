locals {
    sg_ingress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "ingress" ])
    sg_egress_rules = flatten([ for rule_key, rule in var.sg_rules :  rule if rule_key == "egress" ])


    create_security_group = (var.lb_type == "application") && var.create_sg
    alb_security_groups = (var.lb_type != "application") ? [] : (
                                        local.create_security_group ? [ module.alb_security_group[0].security_group_id ] : var.security_groups)

    nlb_eips = { for subnet in var.subnet_mappings : subnet.subnet_id => subnet if lookup(subnet, "create_eip", false) }
}