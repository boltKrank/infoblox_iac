# 1. VPC
resource "aws_vpc" "nios_vpc" {
  cidr_block           = "10.32.0.0/16"
  # These are needed for NIOS to function properly (Public IPs, DNS, etc.)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nios-vpc"
  }
}

# IGW + Public Route Table
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nios_vpc.id
}

# 2b. Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.nios_vpc.id
  cidr_block        = "10.32.2.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    "Name" = "private-subnet"
  }
}


# 2a. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.nios_vpc.id
  cidr_block              = "10.32.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet"
  }
}




resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nios_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}





# 3b. Security Group for Private ENI (optional, if you want to restrict access)

resource "aws_network_interface" "private_eni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.instance_sg.id]
  tags = {
    Name = "priv-eni"
  }
}

# 4. Network Interfaces
resource "aws_network_interface" "public_eni" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.instance_sg.id]

  # automatically assigns a public IPv4
  tags = {
    Name = "pub-eni"
  }
}

resource "aws_eip" "primary_eip" {
  domain = "vpc"
  tags = {
    Name = "Grid-master-eip"
  }
  # This EIP will be associated with the public ENI of the Grid Master instance
}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = aws_network_interface.public_eni.id
  allocation_id        = aws_eip.primary_eip.id
}



