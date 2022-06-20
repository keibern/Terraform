locals {
    ngw_count = var.single_nat_gateway ? 1 : length(var.subnet_public_cidr)
}

#Create VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr
    instance_tenancy     = "default"
    enable_dns_hostnames = true      #default 값이 false

    tags = { 
      Name = "${var.name_tag}-vpc"
    }
}

#Create Subnet Public
resource "aws_subnet" "subnet_public" {
    count                   = length(var.subnet_public_cidr)    
    vpc_id                  = aws_vpc.vpc.id  
    cidr_block              = element(var.subnet_public_cidr, count.index)
    availability_zone       = element(var.subnet_public_az, count.index)
    map_public_ip_on_launch = true  #default 값이 false

    tags = {
        Name = "${var.name_tag}-Subnet-Public-${count.index}"
    }
}

#Create Subnet Private
resource "aws_subnet" "subnet_private" {
    count                   = length(var.subnet_private_cidr)    
    vpc_id                  = aws_vpc.vpc.id  
    cidr_block              = element(var.subnet_private_cidr, count.index)
    availability_zone       = element(var.subnet_private_az, count.index)
    map_public_ip_on_launch = true  #default 값이 false

    tags = {
        Name = "${var.name_tag}-Subnet-Private-${count.index}"
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
    count          = length(var.subnet_public_cidr)
    subnet_id      = element(aws_subnet.subnet_public[*].id, count.index)
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
    count  = var.create_nat_gateway ? local.ngw_count : 0
    vpc    = true  
}

resource "aws_nat_gateway" "ngw" {
    count         = var.create_nat_gateway ? local.ngw_count : 0 
    allocation_id = element(aws_eip.nat_ip[*].id, count.index)
    subnet_id     = element(aws_subnet.subnet_public[*].id, count.index)

    tags = {
        Name = "${var.name_tag}-ngw"
  }
}

#Create Route table - private
resource "aws_route_table" "rt_private" {
    count  = var.create_nat_gateway ? local.ngw_count : 0 
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.ngw[*].id, count.index)
        
    }

    tags = {
        Name = "${var.name_tag}-RouteTable-Private"
    }
}

/*  case1 동작 장애
#Create Route table - private - nogateway
resource "aws_route_table" "rt_private_nogateway" {
    count  = var.nogate_subnet_private ? 1 : 0 
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.ngw[*].id, count.index)
    }

    tags = {
        Name = "${var.name_tag}-RouteTable-Private-nogateway"
    }
}
*/

resource "aws_route_table_association" "rt_private_as" {
    count          = var.create_nat_gateway ? length(var.subnet_private_cidr) : 0 
    subnet_id      = element(aws_subnet.subnet_private[*].id, count.index)
    route_table_id = element(aws_route_table.rt_private[*].id, count.index)
}

/*  case1 동작 장애
resource "aws_route_table_association" "rt_private_nogateway_as" {
    count          = var.nogate_subnet_private ? length(var.subnet_private_cidr) : 0 
    subnet_id      = element(aws_subnet.subnet_private[*].id, count.index)
    route_table_id = element(aws_route_table.rt_private_nogateway[*].id, count.index)
}
*/