data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}


resource "aws_instance" "bastion" {
 
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = var.key_name
  ami = "${data.aws_ami.amazon-linux-2.id}"
  subnet_id = var.public_subnet-1-id
  user_data = <<EOF
  #!/bin/bash
cat << EOTF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOTF
sudo yum install -y kubectl-1.23.0
cat << EOTFF | sudo tee ~/.bashrc
alias k='kubectl'
alias kg='kubectl get'
alias kgpo='kubectl get pod'
EOTFF
source ~/.bashrc
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
  EOF
  vpc_security_group_ids = [var.bastion_sg_id]
   tags = {
    Name = "bastion-vm"
  }
}