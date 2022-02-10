terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile    = var.sso_profile
  region     = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "lab-vpc-daniil"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-subnet-daniil"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab-gateway-daniil"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "lab-rtb-daniil"
  }
}

resource "aws_main_route_table_association" "main-rtb" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "grigorovich314@gmail.com"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClguu9v4rFaVaoc1mPn++1KwvaoQOWyZvgH7NF0v2O5lAAjlhYpVmi4QeJS5gsy4xzbVWJO8iNPFOYlP38dIhlCC9iNaOn8BH9mtPv7ZAg1raGI9QySoHiaTPa0DkBqjoXoiiXBULlrQ4ccf5uMT0BLRbzSGj2cPYshUDnomx9Yr51Zzrm3QyKxFnl889CugLhr+LWYeEN9GM3qEpQKLcFikCrxMr8eKQMzURt9Cg1TEjskHRZJK4ITYoxXCARXiBsX1feiPbFBOQ0fPM4Xa9tyD0Vi5NstM90WYcoYh+32UElqcTlcEv5I1DBQ1uTwXfs30TSvliJRKa+5im+gWVTj9bP21eRM+ul+4I5uUDD46NyNx1V6d2KW9rdRMPyWLjOUvTzkIPgvqWbj2/y0Md1bol9UzNLf1tIf6COQVj2WPtFUWJI/wj9cGcwgn+4j7EKTMxwTFveDAEvaFlPxKF+ai6u4gzgHDV1VNRPfvxErSqcI/MwvZwitLalUymQ17c= grigorovich314@gmail.com"
}

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.ami_instance_type
  subnet_id     = aws_subnet.subnet.id
  key_name = aws_key_pair.deployer.key_name
  iam_instance_profile = "jenkins"
  depends_on = [aws_internet_gateway.gateway]
  root_block_device {
    volume_size = "35"
  }
  tags = {
    Name = "lab-EC2_instance-daniil"
  }
}

resource "aws_cloudwatch_metric_alarm" "my_alarm" {
    alarm_name          = "my_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = 12
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 10
    alarm_description = "Stop the EC2 instance when CPU utilization stays below 10% on average for 12 periods of 5 minutes, i.e. 1 hour"
    alarm_actions     = ["arn:aws:automate:${var.region}:ec2:stop"]
    dimensions = {
        InstanceId = aws_instance.app_server.id
    }
}