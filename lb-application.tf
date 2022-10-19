resource aws_lb "application" {
    count = local.alb ? 1: 0

    name = var.name
    internal = var.internal
    load_balancer_type = var.lb_type

    enable_deletion_protection  = var.enable_deletion_protection
    
    customer_owned_ipv4_pool    = var.customer_owned_ipv4_pool
    ip_address_type             = var.ip_address_type
    desync_mitigation_mode      = var.desync_mitigation_mode

    subnets = var.subnets

    security_groups             = local.security_groups
    drop_invalid_header_fields  = var.drop_invalid_header_fields
    idle_timeout                = var.idle_timeout
    enable_http2                = var.enable_http2
    enable_waf_fail_open        = var.enable_waf_fail_open

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