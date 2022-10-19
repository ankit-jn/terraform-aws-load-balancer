resource aws_lb "network" {
    count = local.nlb ? 1: 0

    name = var.name
    internal = var.internal
    load_balancer_type = var.lb_type

    enable_deletion_protection  = var.enable_deletion_protection
    
    customer_owned_ipv4_pool    = var.customer_owned_ipv4_pool
    ip_address_type             = var.ip_address_type
    desync_mitigation_mode      = var.desync_mitigation_mode
 
    subnets = length(var.subnet_mappings) > 0 ? null : var.subnets
    
    dynamic "subnet_mapping" {    
        for_each = var.subnet_mappings

        content {
            subnet_id            = subnet_mapping.value.subnet_id
            allocation_id        = lookup(subnet_mapping.value, "create_eip", false) ? aws_eip.this[subnet_mapping.value.subnet_id].id : lookup(subnet_mapping.value, "allocation_id", null)
            private_ipv4_address = var.internal ? lookup(subnet_mapping.value, "private_ipv4_address", null) : null
            ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
        }
    }
    enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

    ## Access Logs
    dynamic "access_logs" {
        for_each = var.enable_access_logs ? [1] : []
        content {
            bucket = var.access_logs.bucket
            prefix = lookup(var.access_logs, "prefix", "")
            enabled = var.enable_access_logs
        }
    }

    tags = merge( { "Name" = var.name }, var.default_tags )
}

##################################################################
## Provision Elastic IP for each Subnet Mapping defined for NLB
##################################################################
resource aws_eip "this" {
    for_each = local.nlb ? local.nlb_eips : {}

    vpc = true
    tags = merge(
            {"Name" = format("%s-eip-%s", var.name, each.key)}, 
            var.default_tags
          )
}