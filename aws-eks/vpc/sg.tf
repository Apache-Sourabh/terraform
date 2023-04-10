resource "aws_security_group" "eks-sg" {
  name        = "eks-sg"
  description = "Control EKS inbound/Outbound traffic"
  vpc_id      = aws_vpc.app-cloud.id

  ingress {
    description      = "VPC & Bastion Inbound to EKS"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    security_groups = [aws_default_security_group.default.id, aws_security_group.bastion-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    depends_on = [
      aws_security_group.bastion-sg
    ]
  tags = {
    Name = "eks-sg"
  }
}

resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Control BASTION inbound/Outbound traffic"
  vpc_id      = aws_vpc.app-cloud.id

  ingress {
    description      = "VPC & Internet Inbound to Bastion"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks = ["${aws_vpc.app-cloud.cidr_block}"]
  }

  ingress {
    description      = "VPC & Internet Inbound to Bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}
