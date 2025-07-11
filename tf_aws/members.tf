# NIOS Members (can have multiple members if needed)

locals {
  members = var.members
}

# Data sources for Grid Join Token and Grid Master Certificate



resource "aws_network_interface" "member_mgmt_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.nios_security_group.id]
  private_ips = [cidrhost(aws_subnet.mgmt_subnet.cidr_block, 20 + index(local.members, each.key))] # Assign a unique private IP for each member

  depends_on = [ aws_subnet.mgmt_subnet ]

  tags = {
    Name = "${each.key}-mgmt-nic"
  }
}

resource "aws_network_interface" "member_lan1_nics" {
  for_each        = toset(local.members)
  subnet_id       = aws_subnet.lan1_subnet.id
  security_groups = [aws_security_group.nios_security_group.id]
  private_ips = [cidrhost(aws_subnet.lan1_subnet.cidr_block, 20 + index(local.members, each.key))] # Assign a unique private IP for each member

  tags = {
    Name = "${each.key}-lan1-nic"
  }
}

resource "aws_eip" "member_lan1_eips" {
  for_each = toset(local.members)
  network_interface = aws_network_interface.member_lan1_nics[each.key].id  
  depends_on = [aws_network_interface.member_lan1_nics]

  tags = {
    Name = "${each.key}-lan1-eip"
  }
  # This EIP will be associated with the LAN1 NIC of each member instance
  
}



# Member Instances
resource "aws_instance" "member_instances" {
  for_each      = toset(local.members)
  ami           = var.nios_ami_id
  instance_type = var.grid_member_instance_type
  key_name      = var.key_name
  depends_on    = [aws_instance.grid_master]

  lifecycle {
    ignore_changes = [tags]
  }

  # eth0 (MGMT NIC)
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.member_mgmt_nics[each.key].id
  }

  # eth1 (LAN1 NIC)
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.member_lan1_nics[each.key].id  
  }

  tags = {
    Name = "${each.key}.localdomain"
  }



  #TODO: TOKEN AND CERTIFICATE

  user_data = <<EOF
#infoblox-config
temp_license: enterprise dns dhcp cloud vnios nios IB-V825
remote_console_enabled: y
default_admin_password: ${var.default_admin_password}
accept_eula: true
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
        echo "Still waiting AWS 3/3 Checks..."
        sleep 30
      done
    EOT
  }

    # Add current member to the grid
  provisioner "local-exec" {
    command = <<EOT
      echo "Adding ${each.key}.localdomain"
      ${path.module}/scripts/add_offline_member.sh \
      ${var.username} \
      ${var.default_admin_password} \
      ${aws_eip.grid_master_lan1_eip.public_ip} \
      10.32.2.20 \
      ${var.gateway_ip} \
      ${each.key}.localdomain

      echo "DETAILS: ${var.username} ${var.default_admin_password} ${aws_eip.member_lan1_eips[each.key].public_ip} 10.32.2.10 test"
      EOT
      /*
      sleep 30

      echo "Initiating join for ${each.key}.localdomain"


    EOT */
  }

}

resource "null_resource" "join_member_to_grid" {
  for_each = toset(local.members)
  depends_on = [ aws_instance.member_instances ]

  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for ${each.value} (${aws_eip.member_lan1_eips[each.key].public_ip}) to become ready..."

    for i in {1..30}; do
      if curl -sk --connect-timeout 2 https://${aws_eip.member_lan1_eips[each.key].public_ip}/wapi/v2.12/grid >/dev/null; then
        echo "✅ ${each.value} is up."
        break
      fi
      echo "Still waiting... attempt $i"
      sleep 10
    done

    # Your actual command below
    echo "Joining member ${each.key} to grid"
      ${path.module}/scripts/initiate_member_join.sh \
      ${var.username} \
      ${var.default_admin_password} \
      ${aws_eip.member_lan1_eips[each.key].public_ip} \
      10.32.2.10 \
      test
    EOT
  }

  triggers = {
    instance_id = aws_instance.member_instances[each.key].id
  }


}

