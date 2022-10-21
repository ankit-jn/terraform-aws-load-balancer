resource aws_lb_listener_rule "this" {

    for_each = {for k, v in local.listener_rules: k=> v if (local.alb || local.nlb)}

    listener_arn = aws_lb_listener.this[each.value.listener].arn
    priority     = lookup(each.value, "priority", null)

    ###########################
    ## PREPARE ACTIONS
    ###########################

    ## Action: forward (For a single target group)
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "forward", {}))) > 0 ? [1] : []

        content {
            type = "forward"
            target_group_arn = aws_lb_target_group.this[each.value.actions.forward.target_group].arn
        }
    }

    ## Action: forward (For multiple target groups with weights assigned)
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "weighted_forward", {}))) > 0 ? [1] : []

        content {
            type = "forward"

            forward {
                dynamic "target_group" {
                    for_each = each.value.actions.weighted_forward.target_groups

                    content {
                        arn = aws_lb_target_group.this[target_group.key].arn
                        weight = lookup(target_group.value, "weight", 100)
                    }
                }

                dynamic "stickiness" {
                    for_each = can(each.value.actions.weighted_forward.stickiness) ? [1] : []

                    content {
                      duration = each.value.actions.weighted_forward.stickiness
                      enabled = true
                    }

                }
            }
        }
    }

    ## Action: redirect
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "redirect", {}))) > 0 ? [1] : []

        content {
            type = "redirect"

            redirect {
                status_code = each.value.actions.redirect.status_code     
                path        = lookup(each.value.actions.redirect, "path", null)
                host        = lookup(each.value.actions.redirect, "host", null)
                port        = lookup(each.value.actions.redirect, "port", null)
                protocol    = lookup(each.value.actions.redirect, "protocol", null)
                query       = lookup(each.value.actions.redirect, "query", null)
            }
        }
    }

    ## Action: fixed_response
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "fixed_response", {}))) > 0 ? [1] : []

        content {
            type = "fixed-response"

            fixed_response {
                content_type = each.value.fixed_response.content_type
                message_body = lookup(each.value.actions.fixed_response, "message_body", null)
                status_code  = lookup(each.value.actions.fixed_response, "status_code", null) 
            }
        }
    }

    ## Action: authenticate-cognito
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "authenticate_cognito", {}))) > 0 ? [1] : []

        content {
            type = "authenticate-cognito"

            redirect {
                user_pool_arn                       = each.value.actions.authenticate_cognito.user_pool_arn
                user_pool_client_id                 = each.value.actions.authenticate_cognito.user_pool_client_id
                user_pool_domain                    = each.value.actions.authenticate_cognito.user_pool_domain
                authentication_request_extra_params = lookup(each.value.actions.authenticate_cognito, "authentication_request_extra_params", null)
                on_unauthenticated_request          = lookup(each.value.actions.authenticate_cognito, "on_authenticated_request", null)
                scope                               = lookup(each.value.actions.authenticate_cognito, "scope", null)
                session_cookie_name                 = lookup(each.value.actions.authenticate_cognito, "session_cookie_name", null)
                session_timeout                     = lookup(each.value.actions.authenticate_cognito, "session_timeout", null)
            }
        }
    }

    ## Action: authenticate-oidc
    dynamic "action" {
        for_each = length(keys(lookup(each.value.actions, "authenticate_oidc", {}))) > 0 ? [1] : []

        content {
            type = "authenticate-oidc"

            redirect {
                issuer                              = each.value.actions.authenticate_oidc.issuer
                authorization_endpoint              = each.value.actions.authenticate_oidc.authorization_endpoint
                client_id                           = each.value.actions.authenticate_oidc.client_id
                client_secret                       = each.value.actions.authenticate_oidc.client_secret
                token_endpoint                      = each.value.actions.authenticate_oidc.token_endpoint
                user_info_endpoint                  = each.value.actions.authenticate_oidc.user_info_endpoint
                authentication_request_extra_params = lookup(each.value.actions.authenticate_oidc, "authentication_request_extra_params", null)
                on_unauthenticated_request          = lookup(each.value.actions.authenticate_oidc, "on_unauthenticated_request", null)
                scope                               = lookup(each.value.actions.authenticate_oidc, "scope", null)
                session_cookie_name                 = lookup(each.value.actions.authenticate_oidc, "session_cookie_name", null)
                session_timeout                     = lookup(each.value.actions.authenticate_oidc, "session_timeout", null)
            }
        }
    }

    ###########################
    ## PREPARE Conditions
    ###########################

    ## Condition: host_header
    dynamic "condition" {
        for_each = length(lookup(each.value.conditions, "host_header", [])) > 0 ? [1] : []

        content {
            host_header {
                values = each.value.conditions.host_header
            }
        }
    }

    ## Condition: http_header
    dynamic "condition" {
        for_each = length(keys(lookup(each.value.conditions, "http_header", {}))) > 0 ? [1] : []

        content {
            http_header {
                http_header_name = each.value.conditions.http_header.header_name
                values           = each.value.conditions.http_header.header_values                
            }
        }
    }

    ## Condition: http_request_method
    dynamic "condition" {
        for_each = length(lookup(each.value.conditions, "http_request_method", [])) > 0 ? [1] : []

        content {
            http_request_method {
                values = each.value.conditions.http_request_method
            }
        }
    }
        
    ## Condition: path_pattern
    dynamic "condition" {
        for_each = length(lookup(each.value.conditions, "path_pattern", [])) > 0 ? [1] : []

        content {
            path_pattern {
                values = each.value.conditions.path_pattern
            }
        }
    }

    ## Condition: http_header
    dynamic "condition" {
        for_each = length(lookup(each.value.conditions, "query_string",[])) > 0 ? [1] : []

        content {
            dynamic "query_string" {
                for_each = each.value.conditions.query_string

                content {
                    key   = lookup(query_string.value, "key", null)
                    value = query_string.value["value"]
                }
            }
        }
    }

    ## Condition: source_ip
    dynamic "condition" {
        for_each = length(lookup(each.value.conditions, "source_ip", [])) > 0 ? [1] : []

        content {
            source_ip {
                values = each.value.conditions.source_ip
            }
        }
    }

}