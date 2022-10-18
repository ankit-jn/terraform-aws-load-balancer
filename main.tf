resource aws_lb "this" {

    name = var.name
    internal = var.internal
    load_balancer_type = var.lb_type

    enable_deletion_protection  = var.enable_deletion_protection
    
    customer_owned_ipv4_pool    = var.customer_owned_ipv4_pool
    ip_address_type             = var.ip_address_type
    desync_mitigation_mode      = var.desync_mitigation_mode

    ## Access Logs
    dynamic "access_logs" {
        for_each = var.enable_access_logs ? [1] : []
        content {
            bucket = var.access_logs.bucket
            prefix = lookup(var.access_logs, "prefix", "")
            enabled = var.enable_access_logs
        }
    }
    subnets = var.subnets

    tags = merge( { "Name" = var.name }, var.default_tags )

    ## Application Load Balancer Specific Configurations
    security_groups             = local.alb_security_groups
    drop_invalid_header_fields  = var.drop_invalid_header_fields
    idle_timeout                = var.idle_timeout
    enable_http2                = var.enable_http2
    enable_waf_fail_open        = var.enable_waf_fail_open
    
    ## Network Load Balancer Specific Configurations
    enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
    
    dynamic "subnet_mapping" {
        
        for_each = (var.lb_type == "network") ? var.subnet_mappings : []

        content {
            subnet_id            = subnet_mapping.value.subnet_id
            allocation_id        = lookup(subnet_mapping.value, "create_eip", false) ? aws_eip.this[subnet_mapping.value.subnet_id].id : lookup(subnet_mapping.value, "allocation_id", null)
            private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
            ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
        }
    }
}

##################################################################
## Provision Elastic IP for each Subnet Mapping defined for NLB
##################################################################
resource aws_eip "this" {
    for_each = (var.lb_type == "network") ? local.nlb_eips : {}

    vpc = true
    tags = merge(
            {"Name" = format("%s-eip-%s", var.name, each.key)}, 
            var.default_tags
          )
}

## Security Group for ALB Service/Task
module "alb_security_group" {
    source = "git::https://github.com/arjstack/terraform-aws-security-groups.git"

    count = local.create_security_group ? 1 : 0

    vpc_id = var.vpc_id
    name = coalesce(var.sg_name, format("%s-sg", var.name))

    ingress_rules = local.sg_ingress_rules
    egress_rules  = local.sg_egress_rules
}