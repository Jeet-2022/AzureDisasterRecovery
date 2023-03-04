variable "vm_resource_group" {
  type = string
  description = "Virtual machine resource group name"
}

variable "vm_location" {
  type = string
  description = "Virtual machine location"
}

variable "nic_name" {
  type = string
  description = "Network interface card"
}
variable "vm_subnetId" {
  type = list(string)
  description = "Subnet Id"
}
variable "vm_name" {
  type = string
  description = "Virtual machine name"
}

variable "vm_size" {
  type = string
  description = "Virtual machine size"
}

variable "vm_username" {
    type = string 
    description = "User name for VM"
  
}

variable "vm_password" {
    type = string 
    description = "User name for VM"
  
}

variable "vm_count" {
    type = number
    description = "count the number of instance to be created"
  
}

variable "nic_vm_dependecy" {
  type = any
  
}