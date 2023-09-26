variable "resource_tags" {
  type = map(string)
  default = {
    Env     = "Dev"
    Project = "Terraform Django App"
    Owner   = "Ops"
  }

}

variable "lab_iam_role" {
  type    = string
  default = "LabRole"
}

variable "elb_principal_value" {
  type    = string
  default = "arn:aws:iam::127311923021:root"

}
