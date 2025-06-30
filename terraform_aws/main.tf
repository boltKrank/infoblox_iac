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

#Grid Master 
resource "aws_instance" "nios_gm" {
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

  user_data = <<-EOF
    #!/bin/bash
    echo "set network lan1 ipaddr  10.32.0.10 netmask 255.255.255.0 gateway  10.32.0.1" > /tmp/initscript
    echo "set network lan1 name GridMaster" >> /tmp/initscript
    echo "set password admin Infoblox@312" >> /tmp/initscript
    echo "set hostname gm.infoblox.local" >> /tmp/initscript
    echo "set grid name MyGrid" >> /tmp/initscript
    echo "set grid enable" >> /tmp/initscript
    echo "set grid config_ip  10.32.0.10" >> /tmp/initscript
    echo "set grid config_network 255.255.255.0" >> /tmp/initscript
    echo "set grid config_gateway  10.32.0.1" >> /tmp/initscript
    echo "set grid config_domain infoblox.local" >> /tmp/initscript
    echo "set grid admin_password Infoblox@312" >> /tmp/initscript
    echo "set grid join wait" >> /tmp/initscript
    echo "exit" >> /tmp/initscript
    /infoblox/bin/cli -i < /tmp/initscript
  EOF


#   user_data = <<EOF
# #infoblox-config
# set hostname grid-master
# set timezone "Australia/Sydney"
# set network  10.32.0.10 255.255.255.0  10.32.0.1 eth0
# set gridmaster
# set password "${var.device_password}"
# set grid_name "${var.grid_name}"
# set grid_shared_secret "${var.grid_shared_secret}"
# set remote_console_enabled y
# set temp_license dns dhcp enterprise nios IB-V825
# EOF



#  user_data = <<EOF
# #infoblox-config
# grid_name: "${var.grid_name}"
# set_grid_master: true
# remote_console_enabled: y
# default_admin_password: "${var.device_password}"
# temp_license: dns dhcp enterprise nios IB-V825
# EOF 


  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Infoblox-NIOS-GM" 
    Team = var.team_tag
    Email = var.email_tag
    AwsID = var.AwsID_tag
    Product = var.Product_tag
    Version = var.Version_tag
    Purpose = var.Purpose_tag
  }
}


resource "null_resource" "wait_for_grid_master_instance" {
  depends_on = [aws_instance.nios_gm]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EC2 status checks to pass..."
      INSTANCE_ID=${aws_instance.nios_gm.id}
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



#Grid Members 
resource "aws_instance" "nios_member" {
  ami                      = var.nios_ami_id
  root_block_device {
    volume_size           = var.boot_disk_size
    delete_on_termination = true
  }
  instance_type               = var.nios_aws_instance_type
  key_name                    = aws_key_pair.infoblox_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.member_first.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.member_second.id
    device_index         = 1
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "set network lan1 ipaddr 10.32.0.11 netmask 255.255.255.0 gateway 10.32.0.1" > /tmp/initscript
    echo "set network lan1 name GridMember" >> /tmp/initscript
    echo "set password admin Infoblox@312" >> /tmp/initscript
    echo "set hostname gm1.infoblox.local" >> /tmp/initscript
    echo "set grid join_ip 10.32.0.10" >> /tmp/initscript
    echo "set grid name MyGrid" >> /tmp/initscript
    echo "set grid join_password Infoblox@312" >> /tmp/initscript
    echo "set grid join" >> /tmp/initscript
    echo "exit" >> /tmp/initscript
    /infoblox/bin/cli -i < /tmp/initscript
  EOF

# user_data = <<EOF
# set hostname grid-member
# set timezone "Australia/Sydney"
# set network 10.32.0.11 255.255.255.0 10.32.0.1 eth0
# set membership Infoblox 10.32.0.10 "${var.grid_shared_secret}"
# set password "${var.device_password}"
# reboot
# EOF
  

#   user_data = <<EOF
#   #infoblox-config
# grid_name: "${var.grid_name}"
# grid_master: "${aws_instance.nios_gm.private_ip}" 
# grid_shared_secret: "${var.grid_shared_secret}"
# join_grid: true
# remote_console_enabled: y
# default_admin_password: "${var.device_password}"
# temp_license: dns dhcp enterprise nios IB-V825
# EOF

  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "Infoblox-NIOS-Member" 
    Team = var.team_tag
    Email = var.email_tag
    AwsID = var.AwsID_tag
    Product = var.Product_tag
    Version = var.Version_tag
    Purpose = var.Purpose_tag
  }

  depends_on = [ null_resource.wait_for_grid_master_instance  ] # Ensure the grid master is ready before starting members
}
