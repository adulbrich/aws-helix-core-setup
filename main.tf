terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "aws-capstone1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "volume_size" {
  default = 300
}

# main.tf
resource "aws_vpc" "helix_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "helix-vpc"
  }
}

resource "aws_subnet" "helix_subnet" {
  vpc_id                  = aws_vpc.helix_vpc.id
  cidr_block              = "172.16.10.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "helix-subnet"
  }
}

resource "aws_internet_gateway" "helix_gw" {
  vpc_id = aws_vpc.helix_vpc.id

  tags = {
    Name = "helix-gw"
  }
}

resource "aws_default_route_table" "helix_rt" {
  default_route_table_id = aws_vpc.helix_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.helix_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.helix_gw.id
  }

  tags = {
    Name = "helix-rt"
  }
}

resource "aws_security_group" "helix_sg" {
  name        = "helix-security-group"
  description = "Security group for Helix Core"
  vpc_id      = aws_vpc.helix_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 1666
    to_port     = 1666
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "helix-sg"
  }
}

resource "aws_instance" "helix_server" {
  ami                    = "ami-0423fca164888b941" # RHEL9
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.helix_subnet.id
  vpc_security_group_ids = [aws_security_group.helix_sg.id]
  key_name               = "helix-servers"
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "helix-server"
  }
}

# outputs.tf
output "helix_server_ip" {
  value = aws_instance.helix_server.public_ip
}