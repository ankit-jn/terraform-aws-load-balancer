output "arn" {
    description = "The ARN of the load balancer"
    value       = local.alb ? aws_lb.application[0].arn : (
                                local.gateway ? aws_lb.gateway[0].arn : aws_lb.network[0].arn)
}

output "dns_name" {
    description = "The DNS name of the load balancer."
    value       = local.alb ? aws_lb.application[0].dns_name : (
                                local.gateway ? aws_lb.gateway[0].dns_name : aws_lb.network[0].dns_name)
}

output "zone_id" {
    description = "The canonical hosted zone ID of the load balancer"
    value       = local.alb ? aws_lb.application[0].zone_id : (
                                local.gateway ? aws_lb.gateway[0].zone_id : aws_lb.network[0].zone_id)
}

output "sg_id" {
    description = "The Security Group ID associated to ALB"
    value       = (local.alb && var.create_sg) ? module.security_group[0].security_group_id : ""
}

output "target_groups" {
    description = "The target Groups' ARN"
    value       = {for tg in aws_lb_target_group.this: tg.name => tg.arn}
}

output "listeners" {
    description = "The Listeners' ARN"
    value       = { for listener in aws_lb_listener.this: 
                        format("%s.%s", listener.protocol, listener.port) => listener.arn }
}

output "gateway_listener" {
    description = "Listener ARN for Gateway Load Balancer"
    value       = try(aws_lb_listener.gateway[0].arn, "")
}