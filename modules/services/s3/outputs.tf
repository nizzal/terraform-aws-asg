output "alb_logs_bucket_url" {
  #value = aws_s3_bucket.alb_log_bucket.bucket
  #value = "https://${aws_s3_bucket.alb_log_bucket.id}.s3.amazonaws.com"
  value = "https://${aws_s3_bucket.alb_log_bucket.id}.s3.amazonaws.com"
}

output "s3_logs_id" {
  value = aws_s3_bucket.alb_log_bucket.id
}
