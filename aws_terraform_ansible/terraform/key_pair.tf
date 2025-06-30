resource "aws_key_pair" "infoblox_key" {
  key_name   = "infoblox-key"
  public_key = file("${path.module}/infoblox_key.pub")
}