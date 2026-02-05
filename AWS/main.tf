terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"

}

resource "aws_subnet" "dev-vpc-subnet1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.1.0/24"
    availability_zone = "eu-west-1a"
}

resource "aws_network_interface" "dev-nic1" {
  subnet_id       = aws_subnet.dev-vpc-subnet1.id
  private_ips     = ["10.0.1.10"]

}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "dev-instance1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.dev-nic1.id
  }
  credit_specification {
    cpu_credits = "standard"
  }

}


# create and ataach an internet gateway to the VPC
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id
}


# create a public IP address for the instance and associate it with the network interface
resource "aws_eip" "vm1ip" {
    instance = aws_instance.dev-instance1.id
  
}
