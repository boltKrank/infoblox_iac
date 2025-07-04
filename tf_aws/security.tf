# 3. Security Group (allow SSH + HTTP out)
resource "aws_security_group" "instance_sg" {
  name        = "two-nic-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = aws_vpc.nios_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2114
    to_port     = 2114
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

    ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

    ingress {
    from_port   = 67
    to_port     = 67
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

    ingress {
    from_port   = 68
    to_port     = 68
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

