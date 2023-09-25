resource "aws_vpc" "MainVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.MainVPC.id

  tags = {
    Name = "main-igw"
  }
}


resource "aws_eip" "ngw_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "main_ngw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = aws_subnet.PublicSubnetOne.id

  tags = {
    Name = "NAT GW"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "PublicSubnetOne" {
  vpc_id                  = aws_vpc.MainVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "PublicSubnetTwo" {
  vpc_id                  = aws_vpc.MainVPC.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_subnet" "PrivateSubnetOne" {
  vpc_id            = aws_vpc.MainVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "PrivateSubnetTwo" {
  vpc_id            = aws_vpc.MainVPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Private Subnet 2"
  }
}

# route table implementation
resource "aws_route_table" "default-rt-one" {
  vpc_id = aws_vpc.MainVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Default-Subnet-RT-One"
  }
}

resource "aws_route_table" "ngw-rt-one" {
  vpc_id = aws_vpc.MainVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_ngw.id
  }

  tags = {
    Name = "Private-Subnet-RT-One"
  }
}

resource "aws_route_table_association" "rt_associate_one" {
  subnet_id      = aws_subnet.PublicSubnetOne.id
  route_table_id = aws_route_table.default-rt-one.id
}

resource "aws_route_table_association" "rt_associate_two" {
  subnet_id      = aws_subnet.PublicSubnetTwo.id
  route_table_id = aws_route_table.default-rt-one.id
}

resource "aws_route_table_association" "rt_associate_private_subnet" {
  subnet_id      = aws_subnet.PrivateSubnetOne.id
  route_table_id = aws_route_table.ngw-rt-one.id
}

resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "Allow basic administration"
  vpc_id      = aws_vpc.MainVPC.id

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

resource "aws_security_group" "WebServerSG" {
  name        = "WebServerSG"
  description = "Allow basic administration"
  vpc_id      = aws_vpc.MainVPC.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "WebServerSG"
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

module "alb_s3_logs" {
  source = "./modules/services/s3"

  alb_logs_bucket_name = "my-alb-logs-bucket-4712-now"
  elb_principal_value  = "arn:aws:iam::127311923021:root"
}

module "alb" {
  source = "./modules/services/alb"

  vpc_id            = aws_vpc.MainVPC.id
  public_subnet_one = aws_subnet.PublicSubnetOne.id
  public_subnet_two = aws_subnet.PublicSubnetTwo.id
  #alb_bucket_id = module.alb_s3_logs.alb_logs_bucket_url
  alb_bucket_id = module.alb_s3_logs.s3_logs_id

  depends_on = [module.alb_s3_logs]
}

#module "web_server_asg" {
#  source = "./modules/services/asg"
#
#  vpc_id               = aws_vpc.MainVPC.id
#  asg_max_size         = 4
#  asg_min_size         = 1
#  asg_desired_capacity = 1
#
#  amazon_linux_ami  = "ami-08a52ddb321b32a8c"
#  asg_instance_type = "t2.micro"
#  asg_instance_key  = "vockey"
#}
