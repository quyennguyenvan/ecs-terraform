resource "aws_alb" "alb" {
  count           = var.enable_application_loadbalancer != null ? 1 : 0
  name            = "${var.bastion_name}-alb"
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.alb-sg[0].id]
  tags            = var.default_tags
}


resource "aws_alb_target_group" "trgp" {
  count       = var.enable_application_loadbalancer != null ? 1 : 0
  name        = "${var.bastion_name}-tgrp"
  port        = var.enable_application_loadbalancer.port_expose
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  tags        = var.default_tags
}


resource "aws_alb_listener" "alb-listener" {
  count             = var.enable_application_loadbalancer != null ? 1 : 0
  load_balancer_arn = aws_alb.alb[0].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.trgp[0].id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = var.enable_application_loadbalancer != null ? 1 : 0
  target_group_arn = aws_alb_target_group.trgp[0].arn
  target_id        = module.ec2_instance.id
  port             = var.enable_application_loadbalancer.port_expose
}
#===================================================
# OUTPUT
#===================================================
output "ec2_alb_address" {
  value = {
    for k, v in aws_alb.alb : k => v.dns_name
  }
}
