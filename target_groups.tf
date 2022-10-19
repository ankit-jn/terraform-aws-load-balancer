resource aws_lb_target_group "this" {

    for_each = { for tg in var.target_groups: tg.name => tg } 

    name = each.key

    ## Network Load Balancers do not support the lambda target type.
    ## Application Load Balancers do not support the alb target type.
    target_type = lookup(each.value, "target_type", "instance")

    vpc_id      = var.vpc_id
    port        = local.gateway ? 6081 : lookup(each.value, "port", null)
    protocol    = local.gateway ? "GENEVE" : (
                        (lookup(each.value, "target_type", "instance") != "lambda") ? lookup(each.value, "protocol", "HTTP") : null)
    protocol_version = ((lookup(each.value, "target_type", "instance") != "lambda") && 
                            (lookup(each.value, "protocol", "HTTP") == "HTTP" || 
                                (lookup(each.value, "protocol", "HTTP") == "HTTPS"))) ? lookup(each.value, "protocol_version", "HTTP1") : null

    connection_termination = lookup(each.value, "connection_termination", false)
    deregistration_delay = lookup(each.value, "deregistration_delay", 300)
    load_balancing_algorithm_type = local.alb ? lookup(each.value, "load_balancing_algorithm_type", "round_robin") : null
    preserve_client_ip = lookup(each.value, "preserve_client_ip", null)
    proxy_protocol_v2 = local.nlb ? lookup(each.value, "proxy_protocol_v2", false) : null
    slow_start = lookup(each.value, "slow_start", 0)

    lambda_multi_value_headers_enabled = (lookup(each.value, "target_type", "instance") == "lambda") ? lookup(each.value, "lambda_multi_value_headers_enabled", false) : null
  
    dynamic "health_check" {
        for_each = (length(keys(lookup(each.value, "health_check", {}))) > 0) ? [1] : []

        content {
            enabled             = lookup(each.value.health_check, "enabled", true)
            protocol            = (lookup(each.value, "target_type", "instance") != "lambda") ? lookup(each.value.health_check, "protocol", "HTTP") : null
            path                = lookup(each.value.health_check, "path", null)
            port                = lookup(each.value.health_check, "port", "traffic-port")
            interval            = lookup(each.value.health_check, "interval", 30)
            healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
            unhealthy_threshold = local.nlb ? lookup(each.value.health_check, "healthy_threshold", 3) : lookup(each.value.health_check, "unhealthy_threshold", 3)
            timeout             = lookup(each.value.health_check, "timeout", null)
            matcher             = local.alb ? lookup(each.value.health_check, "matcher", null) : null
        }
    }

    dynamic "stickiness" {
        for_each = (length(keys(lookup(each.value, "stickiness", {}))) > 0) ? [1] : []

        content {
            enabled             = lookup(each.value.stickiness, "enabled", true)
            type                = each.value.stickiness.type
            cookie_name         = (lookup(each.value.stickiness, "type", "") == "app_cookie") ? lookup(each.value.stickiness, "cookie_name", null) : null
            cookie_duration     = (lookup(each.value.stickiness, "type", "") == "lb_cookie") ? lookup(each.value.stickiness, "cookie_duration", 86400 ) : null
        }
    }

    tags = merge( { "Name" = format("%s.%s", var.name, each.key) }, var.default_tags )

}