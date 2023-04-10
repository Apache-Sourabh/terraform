output "vpc_id" {
value= aws_vpc.app-cloud.id  
}

output "vpc_cidr" {
    value = aws_vpc.app-cloud.cidr_block
}

output "public_subnet-1-id" {
    value = aws_subnet.public-1.id
}

output "public_subnet-2-id" {
    value = aws_subnet.public-2.id
}

output "private_subnet-1-id" {
    value = aws_subnet.private-1.id
}

output "private_subnet-2-id" {
    value = aws_subnet.private-2.id
}


output "bastion_sg_id" {
  value = aws_security_group.bastion-sg.id
}

output "eks_sg_id" {
  value = aws_security_group.eks-sg.id
}