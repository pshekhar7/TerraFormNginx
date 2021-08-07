terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}

variable "env" {}
variable "vpc-cidr-block" {}
variable "subnet-cidr-block" {}
variable "az-subnet-1" {}
variable "my-ip" {}
variable "instance-type"{}
variable "key-pair"{}
variable "public-key-file-location" {}

provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc-cidr-block
    tags = {
        Name = "myapp-${var.env}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet-cidr-block
    availability_zone = var.az-subnet-1
    tags = {
        Name = "myapp-${var.env}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "myapp-${var.env}-igw"
    }
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "myapp-${var.env}-route-table"
    }
}

resource "aws_route_table_association" "myapp-rtb-association" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [var.my-ip]
    }

    ingress {
        from_port        = 8080
        to_port          = 8080
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "myapp-${var.env}-sg"
    }

}

data "aws_ami" "amazon-ami-latest" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

output "aws_ami" {
    value = data.aws_ami.amazon-ami-latest
}

resource "aws_key_pair" "myapp-key-pair" {
    key_name = "myapp-key-pair"
    public_key = file(var.public-key-file-location)
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.amazon-ami-latest.id
    instance_type = var.instance-type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    associate_public_ip_address = true
    availability_zone = var.az-subnet-1
    key_name = aws_key_pair.myapp-key-pair.key_name

    tags = {
        Name = "myapp-${var.env}-server"
    }
}

