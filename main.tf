terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}

variable "env" {
    description = "Variable holding the value for current environment"
    type = string
}

variable "vpc-cidr-block" {
    description = "CIDR block for vpc"
    type = string
}

variable "subnet-cidr-block" {
    description = "CIDR block for subnet 1"
    type = string
}

variable "az-subnet-1" {
    description = "AZ for subnet 1"
    type = string
}

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

