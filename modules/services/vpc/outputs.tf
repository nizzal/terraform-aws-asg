output "vpc_id" {
  value = aws_vpc.MainVPC.id
}

output "aws_public_subnets" {
  value = [aws_subnet.PublicSubnetOne.id, aws_subnet.PublicSubnetTwo.id ]
}

output "aws_private_subnets" {
  value = [aws_subnet.PrivateSubnetOne.id, aws_subnet.PrivateSubnetTwo.id ]
}