output "subnet-id" {
  value = aws_subnet.myapp-subnet-1.id
}

output "subnet-az" {
  value = aws_subnet.myapp-subnet-1.availability_zone
}