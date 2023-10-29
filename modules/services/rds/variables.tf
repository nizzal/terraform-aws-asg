variable "multi_az" {
    type = bool
    description = "Multi AZ deployment for RDS instance."
}

variable "rds_user" {
  type = string
  description = "Username for rds instance"
}

variable "instance_class" {
  type = string
  description = "Instance class for rds instance"
}

variable "vpc_id" {
  type = string
  description = "VPC ID for rds instance."
}

variable "private_subnets" {
  type = set(string)
  description = "Subnet groups for rds instance."
}

variable "web_server_sg_id" {
  type = string
  description = "Web server sg to allow access to rds instance."
}