################# VPC #################

module "vpc_v1" {
  source = "../vpc"

  vpc_cidr = var.vpc_cidr
  infra_env = var.infra_env
  public-subnet-1-cidr_block = var.public-subnet-1-cidr_block
  public-subnet-1-az = var.public-subnet-1-az
  public-subnet-2-cidr_block = var.public-subnet-2-cidr_block
  public-subnet-2-az = var.public-subnet-2-az
  private-subnet-1-cidr_block = var.private-subnet-1-cidr_block
  private-subnet-1-az = var.private-subnet-1-az
  private-subnet-2-cidr_block = var.private-subnet-2-cidr_block
  private-subnet-2-az = var.private-subnet-2-az

}

module "eks_v1" {
  source = "../eks"

  infra_env = var.infra_env
  private_subnet-1-id = module.vpc_v1.private_subnet-1-id
  private_subnet-2-id = module.vpc_v1.private_subnet-2-id
  eks_version = var.eks_version
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  disk_size = var.disk_size
  instance_types = var.instance_types
  vpc_id = module.vpc_v1.vpc_id
  eks_sg_id = module.vpc_v1.eks_sg_id
  bastion_sg_id = module.vpc_v1.bastion_sg_id

}

module "bastion_v1" {
  source = "../bastion"

  depends_on = [
    module.eks_v1
  ]
  availability_zone = var.availability_zone
  instance_type = var.instance_type
  key_name = var.key_name
  public_subnet-1-id = module.vpc_v1.public_subnet-1-id
  vpc_id = module.vpc_v1.vpc_id
  bastion_sg_id = module.vpc_v1.bastion_sg_id

}