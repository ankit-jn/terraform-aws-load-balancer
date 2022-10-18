output "arn" {
    description = "The ARN of the load balancer"
    value       = aws_lb.this.arn
}

output "dns_name" {
    description = "The DNS name of the load balancer."
    value       = aws_lb.this.dns_name
}

output "zone_id" {
    description = "The canonical hosted zone ID of the load balancer"
    value       = aws_lb.this.zone_id
}

output "sg_id" {
    description = "The Security Group ID associated to ALB"
    value       = local.create_security_group ? module.alb_security_group[0].security_group_id : ""
}