## Load Balancer Listeners
resource aws_lb_listener "this" {

    for_each = {for k, v in local.listeners: k=> v if (local.alb || local.nlb)}

    load_balancer_arn = local.alb ? aws_lb.application[0].arn : aws_lb.network[0].arn 

    port              = each.value.port
    protocol          = each.value.protocol

    ssl_policy        = contains(["HTTPS", "TLS"], each.value.protocol) ? lookup(each.value, "ssl_policy", var.default_ssl_policy) : null
    certificate_arn   = contains(["HTTPS", "TLS"], each.value.protocol) ? each.value.certificate_arn : null
    alpn_policy       = (each.value.protocol == "TLS") ? lookup(each.value, "alpn_policy", null) : null

    default_action {

        type = lookup(each.value, "action_type", "forward")
        
        order = lookup(each.value, "order", null)

        ## Action: forward
        dynamic "forward" {
            for_each = length(keys(lookup(each.value, "forward", {}))) > 0 ? [1] : []

            content {
              
                dynamic "target_group" {
                    for_each = each.value.forward.target_groups

                    content {
                        arn = aws_lb_target_group.this[target_group.key].arn
                        weight = lookup(target_group.value, "weight", 100)
                    }
                }

                dynamic "stickiness" {
                    for_each = can(each.value.forward.stickiness) ? [1] : []

                    content {
                      duration = each.value.forward.stickiness
                      enabled = true
                    }

                }
            }            
        }

        ## Action: redirect
        dynamic "redirect" {
            for_each = length(keys(lookup(each.value, "redirect", {}))) > 0 ? [1] : []

            content {           
                status_code = each.value.redirect.status_code     
                path        = lookup(each.value.redirect, "path", null)
                host        = lookup(each.value.redirect, "host", null)
                port        = lookup(each.value.redirect, "port", null)
                protocol    = lookup(each.value.redirect, "protocol", null)
                query       = lookup(each.value.redirect, "query", null)
            }            
        }

        ## Action: fixed_response
        dynamic "fixed_response" {
            for_each = length(keys(lookup(each.value, "fixed_response", {}))) > 0 ? [1] : []

            content {
                content_type = each.value.fixed_response.content_type
                message_body = lookup(each.value.fixed_response, "message_body", null)
                status_code  = lookup(each.value.fixed_response, "status_code", null) 
            }            
        }

        ## Action: authenticate-cognito
        dynamic "authenticate_cognito" {
            for_each = (contains(["HTTPS", "TLS"], each.value.protocol) && 
                          length(keys(lookup(each.value, "authenticate_cognito", {}))) > 0) ? [1] : []

            content {
                user_pool_arn                       = each.value.authenticate_cognito.user_pool_arn
                user_pool_client_id                 = each.value.authenticate_cognito.user_pool_client_id
                user_pool_domain                    = each.value.authenticate_cognito.user_pool_domain
                authentication_request_extra_params = lookup(each.value.authenticate_cognito, "authentication_request_extra_params", null)
                on_unauthenticated_request          = lookup(each.value.authenticate_cognito, "on_authenticated_request", null)
                scope                               = lookup(each.value.authenticate_cognito, "scope", null)
                session_cookie_name                 = lookup(each.value.authenticate_cognito, "session_cookie_name", null)
                session_timeout                     = lookup(each.value.authenticate_cognito, "session_timeout", null)
            }            
        }

        ## Action: authenticate-oidc
        dynamic "authenticate_oidc" {
            for_each = (contains(["HTTPS", "TLS"], each.value.protocol) && 
                          length(keys(lookup(each.value, "authenticate_oidc", {}))) > 0) ? [1] : []

            content {
                issuer                              = each.value.authenticate_oidc.issuer
                authorization_endpoint              = each.value.authenticate_oidc.authorization_endpoint
                client_id                           = each.value.authenticate_oidc.client_id
                client_secret                       = each.value.authenticate_oidc.client_secret
                token_endpoint                      = each.value.authenticate_oidc.token_endpoint
                user_info_endpoint                  = each.value.authenticate_oidc.user_info_endpoint
                authentication_request_extra_params = lookup(each.value.authenticate_oidc, "authentication_request_extra_params", null)
                on_unauthenticated_request          = lookup(each.value.authenticate_oidc, "on_unauthenticated_request", null)
                scope                               = lookup(each.value.authenticate_oidc, "scope", null)
                session_cookie_name                 = lookup(each.value.authenticate_oidc, "session_cookie_name", null)
                session_timeout                     = lookup(each.value.authenticate_oidc, "session_timeout", null)
            }            
        }
    }

    tags = merge( { "Name" = each.key }, var.default_tags, lookup(each.value, "tags", {}) )
}

## Listener for Gateway Load Balancer
resource aws_lb_listener "gateway" {
    count = (local.gateway && (length(keys(var.gateway_listener)) > 0)) ? 1 : 0

    load_balancer_arn = aws_lb.gateway[0].arn

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.this[var.gateway_listener.target_group].id

    }
}
