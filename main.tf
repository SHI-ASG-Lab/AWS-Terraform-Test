terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {}

# Variable Declarations

variable "vpc_id" {
    type = string
    default = "vpc-d919cebf"
}
variable "subnet_id" {
    type = string
    default = "subnet-b208dae8"
}
variable "security_group_id" {
    type = string
    default = "sg-947809dd"
}
variable "VMname" {
    type = string
    default = "JakeUbuntuTest"
}

# Reference Existing Default VPC

data "aws_vpc" "default" {
    id = var.vpc_id
}

# Reference Existing Subnet

data "aws_subnet" "default" {
    id = var.subnet_id
}

# Reference Existing Security Group

data "aws_security_group" "default" {
    id = var.security_group_id
}

# Reference Existing Key Pair

data "aws_key_pair" "aws-TF-1" {
  key_name = "aws-TF-1"
  filter {
    name   = "tag:Owner"
    values = ["jisley"]
  }
  filter {
    name = "tag:tool"
    values = ["terraform"]
  }
}

# Make NIC

resource "aws_network_interface" "foo" {
  subnet_id   = data.aws_subnet.default.id
  security_groups = [data.aws_security_group.default.id]
}

# Instance creation

resource "aws_instance" "main" {
  ami           = "ami-009726b835c24a3aa"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
  key_name = data.aws_key_pair.aws-TF-1.key_name
  
  tags = {
    Name = var.VMname
  }
}

# Outputs
  
output "VMname" {
  value = var.VMname
}
output "public_ip" {
  value = aws_instance.main.public_ip
}
output "public_dns" {
  value = aws_instance.main.public_dns
}
output "private_ip" {
  value = aws_instance.main.private_ip
}
output "key_name" {
  value = data.aws_key_pair.aws-TF-1.key_name
}
