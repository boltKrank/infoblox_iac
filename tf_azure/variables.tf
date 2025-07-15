variable "location" {
  default = "Australia East"
}

# vNet and Subnets:

variable "vnet_address_space" {
  default = ["10.32.0.0/16"]
}


# MGMT Subnet
variable "mgmt_subnet_cidr" {
  default = ["10.32.1.0/24"]
}

# LAN1 Subnet
variable "lan1_subnet_cidr" {
  default = ["10.32.2.0/24"]
}

variable "mgmt_nic_private_ip" {
  default = "10.32.1.10"
}

variable "lan1_nic_private_ip" {
  default = "10.32.2.10"
}

variable "public_key" {
  
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "nios_hdd_size" {
  default = 500
  description = "Size of storage on NIOS image"
}

variable "ssh_public_key" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "subscription_id" {
  default = "Azure subscription ID"
}

variable "image_publisher_name" {
  description = "Publisher name of the image(should be infoblox)"
  default = "infoblox"
}

variable "image_offer_name" {
  description = "The name of the VM image offer"
}

variable "image_sku_name" {
  description = "The name of SKU for the VM image"
}

variable "image_version" {
  description = "Version of image used"
  default = "latest"
}

variable "master_size_type" {
  default = "Standard_D2s_v3"
}

variable "default_admin_password" {
  default = "Infoblox@312"
}