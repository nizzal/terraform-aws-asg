variable "vpc_id" {
  description = "Main VPC id"
  type        = string
}

variable "alb_bucket_id" {
  description = "S3 bucket id for storing ALB logs"
  type        = string
}

variable "public_subnet_one" {
  description = "public subnet one id"
  type        = string
}

variable "public_subnet_two" {
  description = "public subnet two id"
  type        = string
}
