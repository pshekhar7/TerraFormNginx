resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc-id
    cidr_block = var.subnet-cidr-block
    availability_zone = var.az-subnet-1
    tags = {
        Name = "myapp-${var.env}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc-id
    tags = {
        Name = "myapp-${var.env}-igw"
    }
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = var.vpc-id
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