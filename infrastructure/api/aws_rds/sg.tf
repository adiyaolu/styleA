
################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {

  name_prefix = "${var.project}-"
  vpc_id      = var.vpc_id
  description = "Aurora PostgreSQL Security Group"

  tags = merge(
    {
      Name = format( "%s-%s-%s", var.project, var.environment, "sg" )
    },
    var.standard_tags,
  )
}

resource "aws_security_group_rule" "ingress" {

  type              = "ingress"
  from_port         = "5306"
  to_port           = "5306"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {

  type              = "egress"
  from_port         = "5306"
  to_port           = "5306"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
