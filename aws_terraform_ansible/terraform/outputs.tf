output "grid_master_ip" {
  value = aws_instance.nios_gm.private_ip
}

output "grid_member_ip" {
  value = aws_instance.nios_member.private_ip
}

output "grid_master_eip" {
  value = aws_eip.gm_eip.public_ip
}

output "grid_member_eip" {
  value = aws_eip.member_eip.public_ip
}