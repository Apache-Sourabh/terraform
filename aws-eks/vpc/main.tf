resource "aws_vpc" "app-cloud" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.infra_env}-vpc"
    env = var.infra_env
  }
}

resource "aws_subnet" "public-1" {
    vpc_id = aws_vpc.app-cloud.id
    cidr_block = var.public-subnet-1-cidr_block
    availability_zone = var.public-subnet-1-az
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-1"
    }  
}

resource "aws_subnet" "public-2" {
    vpc_id = aws_vpc.app-cloud.id
    cidr_block = var.public-subnet-2-cidr_block
    availability_zone = var.public-subnet-2-az
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-2"
    }  
}

resource "aws_subnet" "private-1" {
    vpc_id = aws_vpc.app-cloud.id
    cidr_block = var.private-subnet-1-cidr_block
    availability_zone = var.private-subnet-1-az

    tags = {
        Name = "Private-Subnet-1"
    }  
}

resource "aws_subnet" "private-2" {
    vpc_id = aws_vpc.app-cloud.id
    cidr_block = var.private-subnet-2-cidr_block
    availability_zone = var.private-subnet-2-az

    tags = {
        Name = "Private-Subnet-2"
    }  
}

resource "aws_eip" "NatEip" {
  vpc = true

  tags = {

    Name = "{var.infra_env}-Nat-Eip"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app-cloud.id

  tags = {
    Name = "{var.infra_env}-igw"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.NatEip.id
  subnet_id     = aws_subnet.public-1.id

  tags = {
    Name = "{var.infra_env}-NAT"
  }

  depends_on = [aws_vpc.app-cloud]
}

resource "aws_route_table" "public1_route" {

  vpc_id = aws_vpc.app-cloud.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.infra_env}-rtb-pub-1"
  }
}

resource "aws_route_table" "private1_route" {

  vpc_id = aws_vpc.app-cloud.id

  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id 
  }

  tags = {
    Name = "${var.infra_env}-rtb-pvt-1"
  }
  
}

resource "aws_route_table" "public2_route" {

  vpc_id = aws_vpc.app-cloud.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.infra_env}-rtb-pub-2"
  }
}

resource "aws_route_table" "private2_route" {

  vpc_id = aws_vpc.app-cloud.id

  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id 
  }

  tags = {
    Name = "${var.infra_env}-rtb-pvt-2"
  }
  
}


resource "aws_route_table_association" "public_rtba_1" {
  subnet_id = aws_subnet.public-1.id
  route_table_id = aws_route_table.public1_route.id
  
}

resource "aws_route_table_association" "public_rtba_2" {
  subnet_id = aws_subnet.public-2.id
  route_table_id = aws_route_table.public2_route.id
  
}

resource "aws_route_table_association" "private_rtba_1" {
  subnet_id = aws_subnet.private-1.id
  route_table_id = aws_route_table.private1_route.id
  
}

resource "aws_route_table_association" "private_rtba_2" {
  subnet_id = aws_subnet.private-2.id
  route_table_id = aws_route_table.private2_route.id
  
}


resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.app-cloud.id

   ingress {
    description      = "Intranet VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["${aws_vpc.app-cloud.cidr_block}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}