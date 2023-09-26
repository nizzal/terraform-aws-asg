# get recent ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "Allow basic administration"
  vpc_id      = var.instance_vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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
    Name = "BastionHostSG"
  }
}

resource "aws_instance" "main_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.instance_key
  #subnet_id       = aws_subnet.PublicSubnetOne.id
  subnet_id       = var.instance_subnet
  security_groups = [aws_security_group.BastionSG.id]

  tags = {
    Name = "Bastion Host Instance"
  }
}
