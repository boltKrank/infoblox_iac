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


/*
output "grid_certificate" {
  depends_on = [ aws_instance.grid_master ]
  value = file("${path.module}/grid_master.crt")
}

output "grid" {
  depends_on = [ aws_instance.grid_master ]
  value = jsondecode(file("${path.module}/grid_join_token.json"))

}

*/