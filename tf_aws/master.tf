# 5. EC2 instance with two NICs

# NIOS Grid_Master
resource "aws_instance" "grid_master" {
  ami           = var.nios_ami_id
  instance_type = var.grid_master_instance_type
  key_name      = var.key_name


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


/*
user_data = <<EOF
#infoblox-config
set_grid_master: true
grid_name: "demogrid"
grid_shared_secret: "test"
remote_console_enabled: y
default_admin_password: "Infoblox@312"
temp_license: dns dhcp enterprise nios IB-V825
EOF
*/

user_data = <<EOF
#infoblox-config
set_grid_master: true
grid_name: "demogrid"
grid_shared_secret: "test"
temp_license: nios IB-V825 enterprise dns dhcp
default_admin_password: "Infoblox@312"
remote_console_enabled: y
gridmaster:
EOF


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

  # TODO: local-exec: WAPI to instantiate the Grid. ??? if user_data is sufficient.


}
/*
# Download certificate and token from the Grid Master

resource "null_resource" "get_grid_cert" {
  depends_on = [aws_instance.grid_master]

  # Get Grid certificate and token after the instance is up

  # Certificate download
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for GM to come online..."
      for i in {1..30}; do
        if curl -sk --connect-timeout 5 https://${aws_instance.grid_master.public_ip}/wapidoc/ > /dev/null; then
          break
        fi
        sleep 10
      done
      curl -sk https://${aws_instance.grid_master.public_ip}/infoblox.crt -o ./grid_master.crt
    EOT
  }

  # Token download
    provisioner "local-exec" {
    command = <<EOT
      curl -k -u admin:Infoblox@312 -X POST \
        https://${aws_instance.grid_master.public_ip}/wapi/v2.10/grid?_function=generate_token \
        -H "Content-Type: application/json" \
        -o grid_join_token.json
    EOT
  }


  triggers = {
    gm_ip = aws_instance.grid_master.public_ip
  }
}

*/