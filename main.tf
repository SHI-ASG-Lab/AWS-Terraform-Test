terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {
  region     = "us-west-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

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

# Make NIC

resource "aws_network_interface" "foo" {
  subnet_id   = data.aws_subnet.default.id
  security_groups = [data.aws_security_group.default.id]
/*
  attachment {
    instance = aws_instance.main.id
    device_index = 0
  }
*/
}

# Instance creation

resource "aws_instance" "main" {
  ami           = ami-009726b835c24a3aa
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  tags = {
    Name = "JakesUbuntu"
  }
}