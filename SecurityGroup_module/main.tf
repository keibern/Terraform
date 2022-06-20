#Create Security Group
resource "aws_security_group" "SecurityGroup" {
    name        = "${var.name_tag}_${var.name_tag_sg}"
    vpc_id      = var.vpc_id

    tags = {
        Name = "${var.name_tag}_${var.name_tag_sg}"
    }
}

resource "aws_security_group_rule" "SecurityGroup_ingessRule" {
    count = length(var.SecurityGroup_ingress)
    security_group_id = aws_security_group.SecurityGroup.id

    #type       = "ingress"
    #from_port   = 0
    #to_port     = 0
    #protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]

    #type              = "ingress"
    #from_port         = element(var.SecurityGroup_ingress[*],[count.index])
    #to_port           = element(var.SecurityGroup_ingress[*],[count.index])
    #protocol          = element(var.SecurityGroup_ingress[*],[count.index])
    #cidr_blocks       = element(var.SecurityGroup_ingress[*],[count.index])

    type        = "ingress"
    cidr_blocks = lookup(var.SecurityGroup_ingress[count.index], "cidr_blocks")
    description = lookup(var.SecurityGroup_ingress[count.index], "description")
    from_port   = lookup(var.SecurityGroup_ingress[count.index], "from_port")
    to_port     = lookup(var.SecurityGroup_ingress[count.index], "to_port")
    protocol    = lookup(var.SecurityGroup_ingress[count.index], "protocol")
}

resource "aws_security_group_rule" "SecurityGroup_egessRule" {
    count = length(var.SecurityGroup_egress)
    security_group_id = aws_security_group.SecurityGroup.id

    #type        = "egress"
    #from_port   = 0
    #to_port     = 0
    #protocol    = "-1"
    #cidr_blocks = ["0.0.0.0/0"]

    #type              = "egress"
    #from_port         = element(var.SecurityGroup_egress[count.index])
    #to_port           = element(var.SecurityGroup_egress[count.index])
    #protocol          = element(var.SecurityGroup_egress[count.index])
    #cidr_blocks       = element(var.SecurityGroup_egress[count.index])

    type        = "egress"
    cidr_blocks = lookup(var.SecurityGroup_egress[count.index], "cidr_blocks")
    description = lookup(var.SecurityGroup_egress[count.index], "description")
    from_port   = lookup(var.SecurityGroup_egress[count.index], "from_port")
    to_port     = lookup(var.SecurityGroup_egress[count.index], "to_port")
    protocol    = lookup(var.SecurityGroup_egress[count.index], "protocol")

}




