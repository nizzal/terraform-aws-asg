#variable "instance_security_groups" {
#  type = list
#  description = "Security groups for ec2 instances"
#}

variable "instance_vpc_id" {
  type = string
  description = "Instances to be placed on VPC"
}

variable "instance_subnet" {
  type = string
  description = "Instances to be placed on subnet"
}

variable "instance_type" {
  type = string
  description = "Instances type"
}

variable "instance_key" {
  type = string
  description = "Key for accessing instances"
}