variable "elb_principal_value" {
  type        = string
  description = "Prinicpal value for ELB"
}

variable "alb_logs_bucket_name" {
  type = string
  description = "Bucket name for storing ALB logs"
}
