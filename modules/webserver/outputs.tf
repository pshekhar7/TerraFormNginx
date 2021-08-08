output "aws_ami" {
    value = data.aws_ami.amazon-ami-latest.id
}

output "server_public_ip" {
    value = aws_instance.myapp-server.public_ip
}