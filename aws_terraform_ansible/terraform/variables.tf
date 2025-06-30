variable "infoblox_ami_id" {
  description = "AMI ID for Infoblox NIOS"
  type        = string  
  default     = "ami-0087307ed15552e62" 
}
variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2"
}   

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "ap-southeast-2a" 
  
}

variable "key_name" {
  description = "SSH key pair name for accessing the instances"
  type        = string
  default     = "infoblox-key"  
}