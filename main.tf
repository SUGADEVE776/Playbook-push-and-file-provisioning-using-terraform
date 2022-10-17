locals {
  vpc_id           = "vpc-cae18aa1"
  subnet_id        = "subnet-7105961a"
  ssh_user         = "ubuntu"
  key_name         = "dev"
  private_key_path = "C:/Users/Sugdev/Desktop/dev.pem"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_acc"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-097a2df4ac947655f"
  subnet_id                   = "subnet-7105961a"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  tags = {
    Name = "ANSIBLE"
  }

  connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "sudo apt install git",
      "git clone https://github.com/SUGADEVE776/Playbook-push-and-file-provisioning-using-terraform.git",
      "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} /home/ubuntu/Playbook-push-and-file-provisioning-using-terraform/nginx.yaml"
    ]
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
