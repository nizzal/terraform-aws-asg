variable "resource_tags" {
  type = map(string)
  default = {
    Env     = "Dev"
    Project = "Terraform Django App"
    Owner   = "Ops"
  }

}
variable "amazon_linux_ami" {
  type    = string
  default = "ami-08a52ddb321b32a8c"
}

variable "asg_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "asg_instance_key" {
  type    = string
  default = "vockey"
}

variable "lab_iam_role" {
  type    = string
  default = "LabRole"
}

variable "elb_principal_value" {
  type    = string
  default = "arn:aws:iam::127311923021:root"

}
