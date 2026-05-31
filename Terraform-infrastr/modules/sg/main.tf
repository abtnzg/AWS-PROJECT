resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = var.name })
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)

  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  from_port                = var.ingress_rules[count.index]["from_port"]
  to_port                  = var.ingress_rules[count.index]["to_port"]
  protocol                 = var.ingress_rules[count.index]["protocol"]
  cidr_blocks              = try(var.ingress_rules[count.index]["cidr_blocks"], [])
  ipv6_cidr_blocks         = try(var.ingress_rules[count.index]["ipv6_cidr_blocks"], [])
  source_security_group_id = try(var.ingress_rules[count.index]["source_security_group_id"], null)
  self                     = try(var.ingress_rules[count.index]["self"], false)
  description              = try(var.ingress_rules[count.index]["description"], null)
}

resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)

  type                     = "egress"
  security_group_id        = aws_security_group.this.id
  from_port                = var.egress_rules[count.index]["from_port"]
  to_port                  = var.egress_rules[count.index]["to_port"]
  protocol                 = var.egress_rules[count.index]["protocol"]
  cidr_blocks              = try(var.egress_rules[count.index]["cidr_blocks"], [])
  ipv6_cidr_blocks         = try(var.egress_rules[count.index]["ipv6_cidr_blocks"], [])
  source_security_group_id = try(var.egress_rules[count.index]["source_security_group_id"], null)
  self                     = try(var.egress_rules[count.index]["self"], false)
  description              = try(var.egress_rules[count.index]["description"], null)
}
