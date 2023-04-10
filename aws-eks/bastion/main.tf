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
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2
  EOF
  vpc_security_group_ids = [var.bastion_sg_id]
   tags = {
    Name = "bastion-vm"
  }
}
