resource "aws_security_group" "this" {
  name        = "${var.bastion_name}-admin-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "${var.bastion_name}-admin-sg"
  }, var.default_tags)
}


resource "aws_security_group_rule" "sg-rule-egress" {
  type              = "egress"
  for_each          = var.egress_rules
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  ipv6_cidr_blocks  = null
  prefix_list_ids   = null
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "sg-rule-ingress" {
  for_each          = var.ingress_rules
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  ipv6_cidr_blocks  = null
  prefix_list_ids   = null
  cidr_blocks       = each.value.cidr_blocks == null ? var.allow_cidr_blocks : each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
}
