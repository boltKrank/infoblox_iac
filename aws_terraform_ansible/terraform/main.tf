resource "aws_network_interface" "gm_mgmt" {
  subnet_id       = aws_subnet.gm_subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.infoblox_sg.id]
  tags = {
    Name = "gm-mgmt-nic"
  }
}

resource "aws_network_interface" "gm_lan" {
  subnet_id       = aws_subnet.gm_subnet.id
  private_ips     = ["10.0.1.11"]
  security_groups = [aws_security_group.infoblox_sg.id]
  tags = {
    Name = "gm-lan-nic"
  }
}

resource "aws_network_interface" "member_mgmt" {
  subnet_id       = aws_subnet.member_subnet.id
  private_ips     = ["10.0.2.10"]
  security_groups = [aws_security_group.infoblox_sg.id]
  tags = {
    Name = "member-mgmt-nic"
  }
}

resource "aws_network_interface" "member_lan" {
  subnet_id       = aws_subnet.member_subnet.id
  private_ips     = ["10.0.2.11"]
  security_groups = [aws_security_group.infoblox_sg.id]
  tags = {
    Name = "member-lan-nic"
  }
}

resource "aws_eip" "gm_eip" {
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "member_eip" {
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip_association" "gm_eip_assoc" {
  # instance_id   = aws_instance.nios_gm.id
  allocation_id = aws_eip.gm_eip.id
  network_interface_id = aws_network_interface.gm_mgmt.id
}

resource "aws_eip_association" "member_eip_assoc" {
  # instance_id   = aws_instance.nios_member.id
  allocation_id = aws_eip.member_eip.id
  network_interface_id = aws_network_interface.member_mgmt.id
}

resource "aws_instance" "nios_gm" {
  ami           = var.infoblox_ami_id
  instance_type = "m5.large"
  key_name      = var.key_name
  user_data     = file("gm_user_data.sh")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.gm_mgmt.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.gm_lan.id
  }

  tags = {
    Name = "Infoblox-GM"
  }
}

resource "aws_instance" "nios_member" {
  ami           = var.infoblox_ami_id
  instance_type = "m5.large"
  key_name      = var.key_name
  user_data     = file("member_user_data.sh")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.member_mgmt.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.member_lan.id
  }

  depends_on = [aws_instance.nios_gm]

  tags = {
    Name = "Infoblox-Member"
  }
}


resource "local_file" "ansible_inventory" {
  depends_on = [aws_instance.nios_member]
  content = <<EOF
[grid_master]
${aws_eip.gm_eip.public_ip} ansible_user=admin ansible_ssh_private_key_file=./infoblox_key

[grid_member]
${aws_eip.member_eip.public_ip} ansible_user=admin ansible_ssh_private_key_file=./infoblox_key
EOF
  filename = "../ansible/inventory.ini"
}
