# 1. VPC
resource "aws_vpc" "nios_vpc" {
  cidr_block = "10.32.0.0/16"
  # These are needed for NIOS to function properly (Public IPs, DNS, etc.)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nios-vpc"
  }
}

# Public side of the VPC

# Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nios_vpc.id
}


# Route Table for LAN1 Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.nios_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}


# SUBNETS

# MGMT Subnet
resource "aws_subnet" "mgmt_subnet" {
  vpc_id                  = aws_vpc.nios_vpc.id
  cidr_block              = "10.32.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "nios-grid-mgmt-subnet"
  }
}


# LAN1 Subnet
resource "aws_subnet" "lan1_subnet" {
  vpc_id                  = aws_vpc.nios_vpc.id
  cidr_block              = "10.32.2.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "nios-grid-lan1-subnet"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "lan1_route_table_assoc" {
  subnet_id      = aws_subnet.lan1_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

