variable "key_name" {
  description = "The name of the key pair to use for SSH access to the EC2 instances."
  type        = string
}

variable "grid_master_instance_type" {
  description = "The instance type for the Grid Master EC2 instance."
  type        = string
  default     = "m5.large"

}

variable "grid_member_instance_type" {
  description = "The instance type for the Grid Member EC2 instance."
  type        = string
  default     = "m5.large"

}


variable "nios_ami_id" {
  description = "The AMI ID for NIOS in the ap-southeast-2 region."
  type        = string
  default     = "ami-078772dab3242ee11" # Amazon Linux 2 in ap-southeast-2

}

variable "grid_master_mgmt_private_ip" {
  description = "The private IP address for the Grid Master MGMT NIC."
  type        = string
  default     = "10.32.1.10"
}

variable "grid_master_lan1_private_ip" {
  description = "The private IP address for the Grid Master LAN1 NIC."
  type        = string
  default     = "10.32.2.10"
  
}

variable "gateway_ip" {
  default = "10.32.2.1"
}

variable "username" {
  default = "admin"
}

variable "default_admin_password" {
  default = "Infoblox@312"
}

variable "members" {
  default = ["member01"]
}

variable "default_fqdn" {
  description = "The default fqdn for NIOS"
  default = "infoblox.localdomain"
}