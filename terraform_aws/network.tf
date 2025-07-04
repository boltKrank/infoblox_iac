data "aws_availability_zones" "azs" {
  state = "available"
}

# Create VPC and Subnets for Nios


resource "aws_vpc" "nios" {
  # count      = var.create_networking ? 1 : 0
  cidr_block = "10.32.0.0/16"
  # cidr_block = var.nios_cidr_block

  tags = {
    Name = "${var.name_prefix}-nios-vpc"
  }
}

resource "aws_subnet" "nios_mgmt" {
  # count                   = var.create_networking ? 1 : 0
  vpc_id                  = aws_vpc.nios.id
  cidr_block              = cidrsubnet(aws_vpc.nios.cidr_block, 2, 0)
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = var.public_address ? true : false
  tags = {
    Name = "${var.name_prefix}-nios-mgmt-subnet-${data.aws_availability_zones.azs.names[0]}"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "nios_lan" {
  # count                   = var.create_networking ? 1 : 0
  vpc_id                  = aws_vpc.nios.id
  cidr_block              = cidrsubnet(aws_vpc.nios.cidr_block, 2, 1)
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = var.public_address ? true : false
  tags = {
    Name = "${var.name_prefix}-nios-lan-subnet-${data.aws_availability_zones.azs.names[0]}"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_network_interface" "first" {
  # subnet_id       = var.create_networking ? aws_subnet.nios_mgmt[0].id : var.custom_subnet_ids[0]
  subnet_id = aws_subnet.nios_mgmt.id
  security_groups = [aws_security_group.nios_sg.id]
}
resource "aws_network_interface" "second" {
  # subnet_id       = var.create_networking ? aws_subnet.nios_lan[0].id : var.custom_subnet_ids[1]
  subnet_id = aws_subnet.nios_lan.id
  security_groups = [aws_security_group.nios_sg.id]
}

resource "aws_network_interface" "member_first" {
  # subnet_id       = var.create_networking ? aws_subnet.nios_mgmt[0].id : var.custom_subnet_ids[0]
  subnet_id = aws_subnet.nios_mgmt.id
  security_groups = [aws_security_group.nios_sg.id]
}

resource "aws_network_interface" "member_second" {
  # subnet_id       = var.create_networking ? aws_subnet.nios_lan[0].id : var.custom_subnet_ids[1]
  subnet_id = aws_subnet.nios_lan.id
  security_groups = [aws_security_group.nios_sg.id]
}

resource "aws_eip" "gm_mgmt" {
  network_interface = aws_network_interface.second.id
}

resource "aws_eip" "member_mgmt" {
  network_interface = aws_network_interface.member_second.id  
}

resource "aws_internet_gateway" "nios" {
  # count  = var.create_networking ? 1 : 0
  vpc_id = aws_vpc.nios.id
  tags = {
    Name = "${var.name_prefix}-nios-igw"
  }
}

resource "aws_route" "default_route" {
  # count                  = var.create_networking ? 1 : 0
  route_table_id         = aws_vpc.nios.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nios.id
}