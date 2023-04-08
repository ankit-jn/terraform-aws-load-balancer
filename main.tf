## Security Group for ALB Service/Task
module "security_group" {
    source = "git::https://github.com/ankit-jn/terraform-aws-security-groups.git"

    count = ((local.alb || local.gateway) && var.create_sg) ? 1 : 0

    vpc_id = var.vpc_id
    name = coalesce(var.sg_name, format("%s-sg", var.name))

    ingress_rules = local.sg_ingress_rules
    egress_rules  = local.sg_egress_rules

    tags = merge({"Name" = coalesce(var.sg_name, format("%s-sg", var.name))}, 
                    { "LoadBalancer" = var.name }, var.default_tags)
}