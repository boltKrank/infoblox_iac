output "MGMT_NIC_IP" {
  value = aws_network_interface.mgmt_nic.private_ip
}

output "LAN1_NIC_IP" {
  value = aws_network_interface.lan1_nic.private_ip
}

output "GM_LAN1_EIP" {
  value = aws_eip.grid_master_lan1_eip.public_ip
}

output "MEMBER_EIPS" {
  value = join("\n", [for eip in aws_eip.member_lan1_eips : eip.public_ip])
}