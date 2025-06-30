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
  default     = "ami-078772dab3242ee11"  # Amazon Linux 2 in ap-southeast-2
  
}