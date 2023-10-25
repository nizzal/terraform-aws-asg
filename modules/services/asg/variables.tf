variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired capacity for ASG"
}

variable "asg_max_size" {
  type        = number
  description = "Max capacity for ASG"
}

variable "asg_min_size" {
  type        = number
  description = "Min capacity for ASG"
}


variable "amazon_linux_ami" {
  type        = string
  description = "Amazon linux AMI"
}

variable "asg_instance_type" {
  type        = string
  description = "Auto Scaling Group instance type"
}

variable "asg_instance_key" {
  type        = string
  description = "SSH key to access bastion host"
}

variable "private_subnets" {
  type = list(string)

}

variable "alb_tg_arn" {
  type = string
}

variable "asg_sg_ports" {
  type = list(string)
  description = "List of ports to allow in ASG security groups."
}