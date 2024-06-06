provider "aws" {
}

# Use the aws_ami data source to find the latest Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu AMIs
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "ssh_keys" {
  source = "./modules/ssh_keys"
}

resource "aws_security_group" "etcd_sg" {
  name = "etcd-sg-${terraform.workspace}"

  dynamic "ingress" {
    for_each = terraform.workspace == "dev" ? [1] : [0, 1]

    content {
      from_port   = ingress.value == 1 ? 0 : (ingress.key == 0 ? 22 : 2379)
      to_port     = ingress.value == 1 ? 0 : (ingress.key == 0 ? 22 : 2380)
      protocol    = ingress.value == 1 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id = var.vpc_id
}

resource "aws_instance" "etcd-server" {
  instance_type          = "t3.medium"
  key_name               = module.ssh_keys.ssh_key_name
  user_data              = file("./cloud-init.sh")
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.etcd_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "etcd-server-${terraform.workspace}"
  }
}

# resource "aws_eip" "etcd-eip" {}

# resource "aws_eip_association" "etcd_eip_assoc" {
#   instance_id   = aws_instance.etcd-server.id
#   allocation_id = aws_eip.etcd-eip.id
# }
