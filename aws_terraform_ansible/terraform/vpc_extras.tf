resource "aws_security_group" "infoblox_sg" {
  name        = "infoblox-sg"
  description = "Allow SSH and HTTPS access"
  vpc_id      = aws_vpc.infoblox_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infoblox-sg"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "infoblox-nat-eip"
  }
} 

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.gm_subnet.id
  tags = {
    Name = "infoblox-nat"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.infoblox_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "infoblox-private-rt"
  }
}

resource "aws_route_table_association" "member_private_association" {
  subnet_id      = aws_subnet.member_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}