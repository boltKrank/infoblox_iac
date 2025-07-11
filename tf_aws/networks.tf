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

/* No Public access to MGMT Subnet
# Route Table for MGMT Subnet
resource "aws_route_table" "mgmt_route_table" {
  vpc_id = aws_vpc.nios_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "mgmt-route-table"
  }
} */



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

/*
# Associate Public Route Table with MGMT Subnet
resource "aws_route_table_association" "mgmt_route_table_assoc" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.mgmt_route_table.id
} */

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




/*

OLD CODE

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

resource "aws_network_interface" "public_eni" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.instance_sg.id]

  # automatically assigns a public IPv4
  tags = {
    Name = "pub-eni"
  }
}

# Private side of the VPC


# 2b. Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.nios_vpc.id
  cidr_block        = "10.32.2.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nios_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_interface" "private_eni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.instance_sg.id]
  tags = {
    Name = "priv-eni"
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


resource "aws_eip" "secondary_eip" {
  domain = "vpc"
  tags = {
    Name = "Grid-member-eip2"
  }
  # This EIP will be associated with the public ENI of the Grid Member instance
  
}

resource "aws_eip_association" "secondary_eip_assoc" {
  network_interface_id = aws_network_interface.private_eni.id
  allocation_id        = aws_eip.secondary_eip.id
}

*/