variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "East US"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key"
}
