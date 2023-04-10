## INPUT VALUES FOR VPC MODULE ###

region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
infra_env = "tf-mod"
public-subnet-1-cidr_block = "10.0.0.0/24"
public-subnet-1-az = "us-east-1a"
public-subnet-2-cidr_block = "10.0.1.0/24"
public-subnet-2-az = "us-east-1b"
private-subnet-1-cidr_block = "10.0.2.0/24"
private-subnet-1-az = "us-east-1a"
private-subnet-2-cidr_block = "10.0.3.0/24"
private-subnet-2-az = "us-east-1b"


## INPUT VALUES FOR EKS MODULE ###

eks_version = 1.24
desired_size = 2
max_size = 4
min_size = 2
disk_size = 20
instance_types = "t3.large"

## INPUT VALUES FOR BASTION-VM MODULE ###

availability_zone = "us-east-1a"
instance_type = "t2.micro"
key_name = "aws_kp"