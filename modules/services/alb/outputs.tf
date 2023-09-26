output "alb_tg_arn" {
  value = aws_alb_target_group.ALB-TG.arn
}

output "alb_url" {
  value = "http://${aws_alb.WebServerALB.dns_name}"
}