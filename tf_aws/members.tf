# NIOS Members (can have multiple members if needed)

locals {
 # Skip members (until grid naming is fixed)
 #  members = ["member01", "member02"]
  members = []
}

resource "aws_network_interface" "private_member_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.instance_sg.id]

  tags = {
    Name = "${each.key}-private-nic"
  }
}

resource "aws_network_interface" "public_member_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.instance_sg.id]


  tags = {
    Name = "${each.key}-public-nic"
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
  ami           = var.nios_ami_id 
  instance_type = var.grid_member_instance_type 
  key_name      = var.key_name
  depends_on = [ aws_instance.grid_master ]
  
  lifecycle {
    ignore_changes = [ tags ]
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.private_member_nics[each.key].id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.public_member_nics[each.key].id
  }

  tags = {
    Name = each.key
  }

    user_data = <<EOF
#infoblox-config
grid_name: "demogrid"
grid_shared_secret: "test"
set_grid_master: false
grid_master: "${aws_instance.grid_master.private_ip}"
remote_console_enabled: y
hostname: "gm01"
default_admin_password: "Infoblox@312"
temp_license: dns dhcp enterprise nios IB-V825
EOF


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
  
}

