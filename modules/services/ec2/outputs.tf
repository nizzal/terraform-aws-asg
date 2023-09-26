output "instance_public_ip" {
    value = "Instance IP: ${aws_instance.main_instance.public_ip}"
}