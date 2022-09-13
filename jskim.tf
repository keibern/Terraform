#Create VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_hostnames = true      #default 값이 false

    tags = { 
      Name = "${var.name_tag}-vpc"
    }
}

#Create Subnet Public
resource "aws_subnet" "subnet_public" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = ["10.0.0.0/24", "10.0.1.0/24"]
    availability_zone       = ["ap-northeast-2a", "ap-northeast-2c"]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.name_tag}-Subnet-Public"
    }
}

#Create Subnet Private
resource "aws_subnet" "subnet_private" {
    vpc_id                  = aws_vpc.vpc.id  
    cidr_block              = ["10.0.0.0/24", "10.0.1.0/24"]
    availability_zone       = ["ap-northeast-2a", "ap-northeast-2c"]
    map_public_ip_on_launch = false

    tags = {
        Name = "${var.name_tag}-Subnet-Private"
    }
}

#Create Route table - public
resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.name_tag}-RouteTable-Public"
    }
}

resource "aws_route_table_association" "rt_public_as" {
    subnet_id      = aws_subnet.subnet_public[*].id
    route_table_id = aws_route_table.rt_public.id
}

#Create IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.name_tag}-igw"
  }
}

#Create NGW
resource "aws_eip" "nat_ip" {
    vpc    = true  
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.nat_ip[*].id
    subnet_id     = aws_subnet.subnet_public[*].id

    tags = {
        Name = "${var.name_tag}-ngw"
  }
}

#Create Route table - private
resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw[*].id
    }

    tags = {
        Name = "${var.name_tag}-RouteTable-Private"
    }
}

resource "aws_route_table_association" "rt_private_as" {
    subnet_id      = aws_subnet.subnet_private[*].id
    route_table_id = aws_route_table.rt_private[*].id
}

#Create Security Group
resource "aws_security_group" "Test" {
  name        = "${var.name_tag}-SecurityGroup-Test"
  description = "Allow All traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_tag}-SecurityGroup-Test"
  }
}