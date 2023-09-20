output "launch_template_id" {
  value = aws_launch_template.WebServerLT.id
}

output "alb_endpoint_url" {
  value = "http://${aws_alb.WebServerALB.dns_name}"
}

output "alb_logs_bucket_url" {
  #value = aws_s3_bucket.alb_log_bucket.bucket
  value = "https://${aws_s3_bucket.alb_log_bucket.id}.s3.amazonaws.com"
}
