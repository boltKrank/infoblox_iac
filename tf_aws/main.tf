terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

# 1. VPC
resource "aws_vpc" "nios_vpc" {
  cidr_block           = "10.32.0.0/16"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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




# 5. EC2 instance with two NICs

# NIOS Grid_Master
resource "aws_instance" "grid_master" {
  ami           = var.nios_ami_id
  instance_type = var.grid_master_instance_type
  key_name      = var.key_name


/* user_date example:

  user_data = base64encode(jsonencode({
    vnios_config = {
      type               = "GM"
      lan1_ip            = "10.0.1.10"
      lan1_mask          = "255.255.255.0"
      gateway            = "10.0.1.1"
      name               = "grid-master"
      grid_name          = "DemoGrid"
      grid_shared_secret = "SuperSecret"
      admin_password     = "Infoblox@312"
      temp_license       = ["vnios", "dns", "dhcp", "cloud", "nios", "grid"]
    }
  }))


*/

user_data = <<EOF
#infoblox-config
grid_name: "demogrid"
grid_shared_secret: "test"
set_grid_master: true
remote_console_enabled: y
default_admin_password: "Infoblox@312"
temp_license: dns dhcp enterprise nios IB-V825
EOF

/*
  user_data = base64encode(jsonencode({
    vnios_config = {
      type               = "GM"
      name               = "grid-master"
      grid_name          = "DemoGrid"
      grid_shared_secret = "SuperSecret"
      admin_password     = "Infoblox@312"
      temp_license       = ["vnios", "dns", "dhcp", "cloud", "nios", "grid"]
    }
  }))
*/

lifecycle {
  ignore_changes = [ tags ]
}

  network_interface {
    network_interface_id = aws_network_interface.private_eni.id
    device_index         = 0
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.public_eni.id
  }

  tags = {
    Name = "grid-master"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EC2 status checks to pass..."
      INSTANCE_ID=${aws_instance.grid_master.id}
      while true; do
        STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query 'InstanceStatuses[0].InstanceStatus.Status' --output text)
        if [ "$STATUS" == "ok" ]; then
          echo "Instance status check passed."
          break
        fi
        echo "Still waiting..."
        sleep 30
      done
    EOT
  }


}

# NIOS Members (can have multiple members if needed)

locals {
 # members = ["member1", "member2"]
 members = ["grid_member1", "grid_member2"]
}

resource "aws_network_interface" "public_member_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.instance_sg.id]


  tags = {
    Name = "${each.key}-public-nic"
  }
}

resource "aws_network_interface" "private_member_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.instance_sg.id]

  tags = {
    Name = "${each.key}-private-nic"
  }
}

resource "aws_eip" "public_member_eips" {
  for_each = aws_network_interface.public_member_nics
  domain   = "vpc"
  tags = {
    "Name" = "${each.key}"
  }
}

resource "aws_eip_association" "eip_members_assoc" {
  for_each             = aws_network_interface.public_member_nics
  allocation_id        = aws_eip.public_member_eips[each.key].id
  network_interface_id = each.value.id
}

resource "aws_instance" "member_instances" {
  for_each      = toset(local.members)
  ami           = "ami-078772dab3242ee11"  # Amazon Linux 2 in ap-southeast-2
  instance_type = "t3.micro"
  key_name      = var.key_name
  depends_on = [ aws_instance.grid_master ]

  # Add user_data here
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from ${each.key}" > /var/tmp/hello.txt
              yum update -y
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.public_member_nics[each.key].id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.private_member_nics[each.key].id
  }

  tags = {
    Name = each.key
  }
    #TODO: Change the INSTANCE_IDs to iterage the array of member instances
    provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EC2 status checks to pass..."
      INSTANCE_ID=${self.id}
      while true; do
        STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query 'InstanceStatuses[0].InstanceStatus.Status' --output text)
        if [ "$STATUS" == "ok" ]; then
          echo "Instance status check passed."
          break
        fi
        echo "Still waiting..."
        sleep 30
      done
    EOT
  }

/*

  user_data = <<EOF
{
  "grid_master": "${var.grid_master_ip}",
  "token": "${var.grid_join_token}",
  "host_name": "grid-member-01"
}
EOF


*/


  
}

# 6. (Optional) Output the ENI and instance info
output "instance_id" {
  value = aws_instance.grid_master.private_ip
}

output "public_ip" {
  value = aws_eip.primary_eip.public_ip
}

output "public_ips" {
  value = { for k, eip in aws_eip.public_member_eips : k => eip.public_ip }
}