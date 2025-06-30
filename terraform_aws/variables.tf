variable "nios_ami_id" {
  description = "The AMI ID for the NIOS marketplace image"
  type        = string
}

variable "nios_aws_instance_type" {
  description = "The AWS instance type"
  type        = string
  default     = "t3.medium" #minimum needed for testing, don't use for prod
}

variable "nios_key_pair" {
  description = "They key pair used to access the image"
  type        = string
  default     = "NIOS_key"
}

variable "grid_name" {
  description = "The name of the NIOS Grid"
  type        = string
  default     = "Infoblox-Grid"
  
}

variable "nios_vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-1", "sg-2"] #to throw an error
}

variable "nios_aws_region" {
  description = "The AWS region to deploy the NIOS instance"
  type        = string
  default     = "ap-southeast-2"
}

variable "team_tag" {
  description = "The team responsible for the instance"
  type        = string
  default     = "support"
}

variable "email_tag" {
  description = "The email of the team member responsible for the instance"
  type        = string
  default     = "noreply@infoblox.com"
}

variable "AwsID_tag" {
  description = "The AWS ID of the team member responsible for the instance"
  type        = string
  default     = "noreply"
}

variable "Product_tag" {
  description = "The product name"
  type        = string
  default     = "NIOS"
}
variable "Version_tag" {
  description = "The version of the product"
  type        = string
  default     = "9.0.x"
}
variable "Purpose_tag" {
  description = "The purpose of the instance"
  type        = string
  default     = "Testing Terraform Automation"
}
variable "name_tag" {
  description = "The name of the instance"
  type        = string
  default     = "NIOS-Instance"
  
}

variable "device_password" {  
  description = "The password for the NIOS device"
  type        = string
  default     = "Infoblox" # Change this to a secure password
  
}

variable "nios_vm_model" {
  description = "The NIOS VM Model used for the deployment. https://docs.infoblox.com/display/NAIG/Infoblox+vNIOS+for+AWS+AMI+Shapes+and+Regions"
  type        = string
  default     = "TE-V825"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "nios"
  
}

variable "create_networking" {
  description = "This variable controls the VPC and subnet creation for the nios device. When set to false the custom-vpc-name and custom-subnetwork-name must be set."
  type        = bool
  default     = "true"
}

variable "public_address" {
  description = "This variable controls if the device has a Public IP Address. When set to false the Ansible provisioner will connect to the private IP of the device."
  type        = bool
  default     = "true"
}

variable "custom_vpc_id" {
  description = "This field can be used to specify an existing VPC for the device. The create-networking variable must also be set to false for this network to be used."
  type        = string
  default     = null
}
variable "custom_subnet_ids" {
  description = "This field can be used to specify a list of 2 existing VPC Subnets for the NIOS device with the 1st being for mgmt and 2nd for LAN. The create-networking variable must also be set to false for this network to be used."
  type        = list(string)
  default     = null
}
variable "nios_cidr_block" {
  description = "The CIDR that will be used for creating a subnet in the VPC when create_network=true - a /16 should be provided"
  type        = string
  default     = "10.255.0.0/16"
}

variable "boot_disk_size" {
  description = "The boot disk size for the nios device"
  type        = number
  default     = 500
  validation {
    condition     = var.boot_disk_size >= 250
    error_message = "The device root disk size should be greater than or equal to 250 GB."
  }
}

variable "create_iam" {
  description = "Create IAM Service Account, Roles, and Role Bindings for NIOS"
  type        = bool
  default     = "false"
}

variable "custom_tags" {
  description = "Custom tags added to AWS Resources created by the module"
  type        = map(string)
  default     = {}
}

variable "grid_shared_secret" {
  description = "The shared secret for the NIOS Grid"
  type        = string
  default     = "test"  
}