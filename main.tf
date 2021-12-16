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
  region     = var.TF_VARS_AWS_DEFAULT_REGION
  access_key = var.TF_VARS_AWS_ACCESS_KEY_ID
  secret_key = var.TF_VARS_AWS_SECRET_ACCESS_KEY
}
# Variable Declarations
variable "TF_VARS_AWS_DEFAULT_REGION" {
    type = string
}
variable "TF_VARS_AWS_ACCESS_KEY_ID" {
    type = string
}
variable "TF_VARS_AWS_SECRET_ACCESS_KEY" {
    type = string
}
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
    default = "JakesUbuntu"
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
/*
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
*/
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

  tags = {
    Name = var.VMname
  }
}
