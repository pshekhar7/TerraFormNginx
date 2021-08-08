resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc-id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my-ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myapp-${var.env}-sg"
  }

}

data "aws_ami" "amazon-ami-latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "myapp-key-pair" {
  key_name   = "myapp-key-pair"
  public_key = file(var.public-key-file-location)
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.amazon-ami-latest.id
  instance_type = var.instance-type

  subnet_id                   = var.subnet-id
  vpc_security_group_ids      = [aws_security_group.myapp-sg.id]
  associate_public_ip_address = true
  availability_zone           = var.subnet-az
  key_name                    = aws_key_pair.myapp-key-pair.key_name
  user_data                   = file("${path.module}/script/launch-server.sh")

  tags = {
    Name = "myapp-${var.env}-server"
  }
}
