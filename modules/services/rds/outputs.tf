output "rds-endpoint" {
  value = aws_db_instance.main_rds.address
}