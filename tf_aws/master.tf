# 5. EC2 instance with two NICs


resource "aws_network_interface" "mgmt_nic" {
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.nios_security_group.id]

  # Specify the private IP address for the MGMT NIC
  private_ips      = [var.grid_master_mgmt_private_ip]
  # Ensure the MGMT NIC is created before the EIP
  depends_on = [aws_subnet.mgmt_subnet] 

  tags = {
    Name = "master-mgmt-nic0"
  }

}

# EIP for Grid Master MGMT NIC
/*
resource "aws_eip" "grid_master_mgmt_eip" {
  network_interface = aws_network_interface.mgmt_nic.id
  depends_on = [ aws_network_interface.mgmt_nic ] # Ensure MGMT NIC is created before EIP

  tags = {
    Name = "grid-master-mgmt-eip"
  }
}
*/

# NIOS Grid LAN1 NIC (this is used for SSH)
resource "aws_network_interface" "lan1_nic" {
  subnet_id       = aws_subnet.lan1_subnet.id
  security_groups = [aws_security_group.nios_security_group.id]

  # Specify the private IP address for the LAN1 NIC
  private_ips      = [var.grid_master_lan1_private_ip]

  tags = {
    Name = "master-lan1-nic1"
  }
}

# EIP for Grid Master LAN1 NIC
resource "aws_eip" "grid_master_lan1_eip" {

  network_interface = aws_network_interface.lan1_nic.id 
  depends_on = [ aws_network_interface.lan1_nic ]
  
  tags = {
    Name = "grid-master-eip"
  }
}


# NIOS Grid_Master
resource "aws_instance" "grid_master" {
  ami           = var.nios_ami_id
  instance_type = var.grid_master_instance_type
  key_name      = var.key_name
  

  # Primary (eth0) MGMT NIC
  network_interface {
    network_interface_id = aws_network_interface.mgmt_nic.id
    device_index         = 0
  }

  # Secondary (eth1) LAN1 NIC
  network_interface {
    network_interface_id = aws_network_interface.lan1_nic.id
    device_index         = 1
  }


  tags = {
    Name = "grid-master"
  }



# Testing info from here https://docs.infoblox.com/space/DeploymentGuidevNIOSforAWS/736395530/Deploy+vNIOS+Instance+in+AWS#Deploy-From-Marketplace

# Raise RFE for grid_name. host_name

  user_data = <<EOF
#infoblox-config 
remote_console_enabled: y
default_admin_password: ${var.default_admin_password}
temp_license: enterprise dns dhcp cloud nios IB-V825
set_grid_master: true.  # FAIL
host_name: "grid-master-01" # FAIL
grid_name: "demo-grid" # FAIL
accept_eula: true #FAIL 
EOF

  # Waiting for EC2 instance to be ready
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
        echo "Still waiting for AWS Checks 3/3..."
        sleep 30
      done
    EOT
  }



}

# Rename grid master
resource "null_resource" "renaming_grid_master" {

  depends_on = [ aws_instance.grid_master ]

  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for Grid Master's API to come online"

    for i in {1..30}; do
      if curl -sk --connect-timeout 2 https://${aws_eip.grid_master_lan1_eip.public_ip}/wapi/v2.12/grid >/dev/null; then
        echo "Grid master API is up."
        break
      fi
      echo "Still waiting... attempt $i"
      sleep 10
    done

    #Renaming the grid master

    echo "Renaming Grid Master..."
    # REF=$(curl -sk -u admin:Infoblox@312 https://${aws_eip.grid_master_lan1_eip.public_ip}/wapi/v2.12/member|jq -r '.[0]._ref')

    REF=$(curl -k -u admin:Infoblox@312 "https://${aws_eip.grid_master_lan1_eip.public_ip}/wapi/v2.12/member" |jq -r '.[] | select(.host_name == "${var.default_fqdn}") | ._ref')
    
    echo "The GM's REF is $REF" 

    curl -k -u admin:Infoblox@312 -X PUT \
      "https://${aws_eip.grid_master_lan1_eip.public_ip}/wapi/v2.10/$REF" \
      -H "Content-Type: application/json" \
      -d '{"host_name": "grid-master-01.localdomain"}'
    EOT

  }

  triggers = {
    instance_id = aws_instance.grid_master.id
  }


}
