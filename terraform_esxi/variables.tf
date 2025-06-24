variable "username" {
  description = "Username for ESXi host"
  type        = string
  default     = "root"  # Default value can be overridden in terraform.tfvars
  
}

variable "password" {
  description = "Password for ESXi host"
  type        = string
  default     = "Infoblox312"  # Default value can be overridden in terraform.tfvars            
  
}