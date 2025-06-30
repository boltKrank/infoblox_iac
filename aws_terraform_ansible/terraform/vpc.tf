resource "aws_vpc" "infoblox_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "infoblox-vpc"
  }
}

resource "aws_subnet" "gm_subnet" {
  vpc_id     = aws_vpc.infoblox_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "gm-subnet"
  }
}

resource "aws_subnet" "member_subnet" {
  vpc_id     = aws_vpc.infoblox_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "member-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.infoblox_vpc.id

  tags = {
    Name = "infoblox-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.infoblox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "infoblox-route-table"
  }
}

resource "aws_route_table_association" "gm_association" {
  subnet_id      = aws_subnet.gm_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "member_association" {
  subnet_id      = aws_subnet.member_subnet.id
  route_table_id = aws_route_table.route_table.id
}