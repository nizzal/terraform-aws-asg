#output "launch_template_id" {
#  value = aws_launch_template.WebServerLT.id
#}

#output "alb_endpoint_url" {
#  value = "http://${aws_alb.WebServerALB.dns_name}"
#}

output "alb_log_s3_bucket" {
  value = module.alb_s3_logs.alb_logs_bucket_url
}
