output "nios_public_address" {
  description = "Public IP Addresses for the NIOS Device"
  value       = aws_eip.gm_mgmt.public_ip
}

output "nios_gm_private_address" {
  description = "The Private IP Addresses allocated for the NIOS Grid Master"
  value       = aws_instance.nios_gm.private_ip
}

output "nios_member_public_address" {
  description = "Public IP Addresses for the NIOS Grid Members"
  value       = aws_eip.member_mgmt.public_ip
  
}

output "nios_member_private_address" {
  description = "The Private IP Addresses allocated for the NIOS Grid Members"
  value       = aws_instance.nios_member[*].private_ip  
}