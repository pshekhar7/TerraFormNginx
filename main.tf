terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
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

module "myapp-subnet" {
  source = "./modules/subnet"

  env               = var.env
  vpc-id            = aws_vpc.myapp-vpc.id
  subnet-cidr-block = var.subnet-cidr-block
  az-subnet-1       = var.az-subnet-1
}

module "myapp-webserver" {
  source = "./modules/webserver"
  
  env                      = var.env
  vpc-id                   = aws_vpc.myapp-vpc.id
  my-ip                    = var.my-ip
  public-key-file-location = var.public-key-file-location
  instance-type            = var.instance-type
  subnet-id                = module.myapp-subnet.subnet-id
  subnet-az                = module.myapp-subnet.subnet-az
}

