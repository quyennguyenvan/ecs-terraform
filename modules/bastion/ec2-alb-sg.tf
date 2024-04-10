resource "aws_security_group" "alb-sg" {
  count       = var.enable_application_loadbalancer != null ? 1 : 0
  name        = "${var.bastion_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({
    Name = "${var.bastion_name}-alb-sg"
  }, var.default_tags)
}


resource "aws_security_group" "task-sg" {
  count       = var.enable_application_loadbalancer != null ? 1 : 0
  name        = "${var.bastion_name}-task-sg"
  description = "Allow inbound access to ECS tasks from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.enable_application_loadbalancer.port_expose
    to_port         = var.enable_application_loadbalancer.port_expose
    security_groups = [aws_security_group.alb-sg[0].id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({
    Name = "${var.bastion_name}-task-sg"
  }, var.default_tags)
}
