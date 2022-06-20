#Create VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.cidr
    instance_tenancy     = "default"
    enable_dns_hostnames = true      #default 값이 false

    tags = {
        Name = "${var.vpc_tags["Name"]}"
    }
   
    /*
    tags = merge(
    var.vpc_tags, var.cidr
    )
    */
}

/*
#Create Subnet Public
resource "aws_subnet" "sub-pub1-10-0-1-0" {
    vpc_id                  = aws_vpc.vpc-10-0-0-0.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "ap-northeast-2a"
    map_public_ip_on_launch = true  #default 값이 false

    tags = {
        Name = "sub-pub1-10-0-1-0"
    }
}

resource "aws_subnet" "sub-pub2-10-0-2-0" {
    vpc_id                  = aws_vpc.vpc-10-0-0-0.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "ap-northeast-2c"
    map_public_ip_on_launch = true  #default 값이 false

    tags = {
        Name = "sub-pub2-10-0-2-0"
    }
}

#Create Subnet Private
resource "aws_subnet" "sub-pri1-10-0-3-0" {
    vpc_id              = aws_vpc.vpc-10-0-0-0.id
    cidr_block          = "10.0.3.0/24"
    availability_zone   = "ap-northeast-2a"
    
    tags = {
        Name = "sub-pri1-10-0-3-0"
    }
}

resource "aws_subnet" "sub-pri2-10-0-4-0" {
    vpc_id              = aws_vpc.vpc-10-0-0-0.id
    cidr_block          = "10.0.4.0/24"
    availability_zone   = "ap-northeast-2c"
    
    tags = {
        Name = "sub-pri2-10-0-4-0"
    }
}

#Create IGW
resource "aws_internet_gateway" "igw-vpc-10-0-0-0" {
    vpc_id = aws_vpc.vpc-10-0-0-0.id

    tags = {
        Name = "igw-vpc-10-0-0-0"
  }
}

#Create Route table - public
resource "aws_route_table" "rt-pub-vpc-10-0-0-0" {
    vpc_id = aws_vpc.vpc-10-0-0-0.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-vpc-10-0-0-0.id
    }

    tags = {
        Name = "rt-pub-vpc-10-0-0-0"
    }
}

resource "aws_route_table_association" "rt-pub-as1-vpc-10-0-0-0" {
    subnet_id = aws_subnet.sub-pub1-10-0-1-0.id
    route_table_id = aws_route_table.rt-pub-vpc-10-0-0-0.id
}

resource "aws_route_table_association" "rt-pub-as2-vpc-10-0-0-0" {
    subnet_id = aws_subnet.sub-pub2-10-0-2-0.id
    route_table_id = aws_route_table.rt-pub-vpc-10-0-0-0.id
}

#Create NGW
resource "aws_eip" "nat-2a" {
    vpc = true  
}

resource "aws_eip" "nat-2c" {
    vpc = true  
}

resource "aws_nat_gateway" "natgw-2a" {
    allocation_id = aws_eip.nat-2a.id
    subnet_id = aws_subnet.sub-pub1-10-0-1-0.id

    tags = {
        Name = "gw NAT-2a"
    }  
}

resource "aws_nat_gateway" "natgw-2c" {
    allocation_id = aws_eip.nat-2c.id
    subnet_id = aws_subnet.sub-pub2-10-0-2-0.id

    tags = {
        Name = "gw NAT-2c"
    }  
}

#Create Route table - private
resource "aws_route_table" "rt-pri1-vpc-10-0-0-0" {
    vpc_id = aws_vpc.vpc-10-0-0-0.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw-2a.id
    }

    tags = {
        Name = "rt-pri1-vpc-10-0-0-0"
    }
}

resource "aws_route_table" "rt-pri2-vpc-10-0-0-0" {
    vpc_id = aws_vpc.vpc-10-0-0-0.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw-2c.id
    }

    tags = {
        Name = "rt-pri2-vpc-10-0-0-0"
    }
}

resource "aws_route_table_association" "rt-pri1-as1-vpc-10-0-0-0" {
    subnet_id = aws_subnet.sub-pri1-10-0-3-0.id
    route_table_id = aws_route_table.rt-pri1-vpc-10-0-0-0.id
}

resource "aws_route_table_association" "rt-pri2-as2-vpc-10-0-0-0" {
    subnet_id = aws_subnet.sub-pri2-10-0-4-0.id
    route_table_id = aws_route_table.rt-pri2-vpc-10-0-0-0.id
}

#EC2 AMI Search
data "aws_ami" "amzn2" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"] #Canonical
}

#Create ASG Security Group
resource "aws_security_group" "tf-asg-sg" {
    name        = "tf-asg-sg"
    description = "Allow web-asg inbound traffic"
    vpc_id      = aws_vpc.vpc-10-0-0-0.id

    ingress {
        description = "tf-asg-sg from VPC"
        from_port   = 0
        to_port     =  0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     =  0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "tf-asg-sg"
    }
}

#Create ALB Security group
resource "aws_security_group" "tf-asg-alb-sg" {
    name        = "tf-asg-alb-sg"
    description = "tf-asg-alb-sg from VPC"
    vpc_id      = aws_vpc.vpc-10-0-0-0.id

    ingress {
        description = "tf-asg-sg from VPC"
        from_port   = 0
        to_port     =  0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     =  0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "tf-asg-alb-sg"
    }  
}

#Create LB
resource "aws_lb" "tf-asg-alb" {
    name                        = "tf-asg-alb"
    internal                    = false
    load_balancer_type          = "application"
    security_groups             = [aws_security_group.tf-asg-alb-sg.id]
    subnets                     = [aws_subnet.sub-pub1-10-0-1-0.id, aws_subnet.sub-pub2-10-0-2-0.id]
    enable_deletion_protection  = false

    tags = {
        Name = "tf-asg-alb-sg"
    }
}

#Create Target Group
resource "aws_lb_target_group" "tg-asg-alb-tg" {
    name = "tf-asg-alb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc-10-0-0-0.id

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 5
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "tf-asg-alb-ln" {
    load_balancer_arn   = aws_lb.tf-asg-alb.arn
    port                = "80"
    protocol            = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tg-asg-alb-tg.arn
    }
}

#Create launch Template
resource "aws_launch_configuration" "as_conf" {
    name_prefix             = "terraform-lc-example-"   #고유한 이름으로 지어줌
    image_id                = data.aws_ami.amzn2.id
    instance_type           = "t2.micro"
    #iam_instance_profile   = "AsgTestRule"
    security_groups         = [aws_security_group.tf-asg-sg.id]
    key_name                = "unicloud"
    user_data               = file("./userdata.sh")

    lifecycle {
      create_before_destroy = true
    }  
}

#Create Auto Scaling Group
resource "aws_autoscaling_group" "tf-asg" {
    name                        = "terraform-asg-example"
    max_size                    = 4
    min_size                    = 2
    health_check_grace_period   = 5
    health_check_type           = "EC2"
    desired_capacity            = 2
    force_delete                = true
    launch_configuration         = aws_launch_configuration.as_conf.name
    vpc_zone_identifier         = [aws_subnet.sub-pri1-10-0-3-0.id, aws_subnet.sub-pri2-10-0-4-0.id]

    tag {
        key                 = "Name"
        value               = "tf-asg"
        propagate_at_launch = true
        # false로 지정하면 생성된 EC2가 설정한 tf-tag를 달고 생성됨
    }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.tf-asg.id
    lb_target_group_arn = aws_lb_target_group.tg-asg-alb-tg.arn  
}

resource "aws_autoscaling_policy" "target-tracking-policy" {
    name                        = "target-tracking-policy"
    policy_type                 = "TargetTrackingScaling"
    estimated_instance_warmup   = 60
    autoscaling_group_name      = aws_autoscaling_group.tf-asg.name

    #CPU 사용율
    target_tracking_configuration {
        predefined_metric_specification{
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 40.0
    }
}

*/