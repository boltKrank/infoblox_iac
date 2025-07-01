# 6. (Optional) Output the ENI and instance info
output "instance_id" {
  value = aws_instance.grid_master.private_ip
}

output "public_ip" {
  value = aws_eip.primary_eip.public_ip
}

output "public_ips" {
  value = { for k, eip in aws_eip.public_member_eips : k => eip.public_ip }
}