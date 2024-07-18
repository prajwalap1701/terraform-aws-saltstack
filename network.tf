resource "aws_security_group" "saltstack_sg" {
  name        = "saltstack"
  description = "Allow salt master and minion communication"

  tags = {
    Name = "salt_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.saltstack_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_saltmaster_port_1" {
  security_group_id = aws_security_group.saltstack_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 4505
  ip_protocol       = "tcp"
  to_port           = 4505
}

resource "aws_vpc_security_group_ingress_rule" "allow_saltmaster_port_2" {
  security_group_id = aws_security_group.saltstack_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 4506
  ip_protocol       = "tcp"
  to_port           = 4506
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.saltstack_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
