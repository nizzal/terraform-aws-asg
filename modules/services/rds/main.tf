resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"

  subnet_ids = var.private_subnets

  tags = {
    Name = "RDS DB SubnetGroup"
  }

}

resource "aws_db_parameter_group" "default" {
  name   = "rds-mysql"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_security_group" "rdsSG" {
  name        = "RDS-SG"
  description = "Allow db access to webserver sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "MYSQL PORT from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.web_server_sg_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "RDS-SG"
  }
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "-_"
}

resource "aws_db_instance" "main_rds" {
  allocated_storage    = 20
  db_name              = "django_app_db"
  identifier           = "appserver-db"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = var.instance_class
  username             = var.rds_user
  password             = random_password.rds_password.result
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = var.multi_az
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [ aws_security_group.rdsSG.id ]

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}

resource "aws_ssm_parameter" "ssm_rds_endpoint" {
  name        = "/rds/endpoint"
  description = "The parameter description"
  type        = "SecureString"
  value       = aws_db_instance.main_rds.address
}

resource "aws_ssm_parameter" "ssm_rds_password" {
  name        = "/rds/password"
  description = "The parameter description"
  type        = "SecureString"
  value       = random_password.rds_password.result
}
