#output "launch_template_id" {
#  value = aws_launch_template.WebServerLT.id
#}

#output "alb_endpoint_url" {
#  value = "http://${aws_alb.WebServerALB.dns_name}"
#}

output "alb_log_s3_bucket" {
  value = module.alb_s3_logs.alb_logs_bucket_url
}

output "alb_tg_arn" {
  value = module.alb.alb_tg_arn
}

output "alb_http_url" {
  value = module.alb.alb_url
}

output "instance_public_ip" {
  value = module.ec2_bastion_host.instance_public_ip
}

output "rds_instance_endpoint" {
  value = module.rds_instance.rds-endpoint
}