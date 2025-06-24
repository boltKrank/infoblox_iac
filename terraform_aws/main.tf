locals {
  nios_vm_model = {
    "TE-V825"  = "r4.large",
    "TE-V1425" = "r3.xlarge"
    "TE-V2225" = "r4.2xlarge"
  }
  nios_license = {
    "TE-V825"  = "IB-V825",
    "TE-V1425" = "IB-V1425"
    "TE-V2225" = "IB-V2225"
  }
}


provider "aws" {
  region = var.nios_aws_region 
}

resource "tls_private_key" "infoblox_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "infoblox_key" {
  key_name   = "infoblox-key"
  public_key = tls_private_key.infoblox_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.infoblox_key.private_key_pem
  filename        = "${path.module}/infoblox-key.pem"
  file_permission = "0600"
}

resource "aws_iam_instance_profile" "nios" {
  count = var.create_iam ? 1 : 0
  name  = "${var.name_prefix}_nios_iam_profile"
  role  = aws_iam_role.vdiscovery[0].id
}

resource "aws_instance" "nios" {
  ami                         = var.nios_ami_id
  root_block_device {
    volume_size           = var.boot_disk_size
    delete_on_termination = true
  }
  instance_type               = var.nios_aws_instance_type
  key_name                    = aws_key_pair.infoblox_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.first.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.second.id
    device_index         = 1
  }

  user_data = <<EOF
#infoblox-config
remote_console_enabled: y
default_admin_password: "${var.device_password}"
temp_license: dns dhcp enterprise nios IB-V825 
EOF

  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Infoblox-NIOS" 
    Team = var.team_tag
    Email = var.email_tag
    AwsID = var.AwsID_tag
    Product = var.Product_tag
    Version = var.Version_tag
    Purpose = var.Purpose_tag
  }
}
