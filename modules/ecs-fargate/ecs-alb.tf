resource "aws_alb" "alb" {
  count           = var.enable_application_loadbalancer ? 1 : 0
  name            = "${var.ecs_cluster_name}-alb"
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.alb-sg.id]
  tags            = var.default_tags
}


resource "aws_alb_target_group" "trgp" {
  count       = var.enable_application_loadbalancer ? 1 : 0
  name        = "${var.ecs_cluster_name}-tgrp"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.default_tags
}


resource "aws_alb_listener" "alb-listener" {
  count             = var.enable_application_loadbalancer ? 1 : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.trgp[0].id
    type             = "forward"
  }
}

#===================================================
# OUTPUT
#===================================================
output "alb_address" {
  value = {
    for k, v in aws_alb.alb : k => v.dns_name
  }
}
