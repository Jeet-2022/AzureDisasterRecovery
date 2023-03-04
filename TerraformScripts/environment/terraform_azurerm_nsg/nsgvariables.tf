variable "nsg_name" {
    type = string
    description = "Network security group name"
  
}
variable "nsg_location" {
    type = string
    description = "Network security group location"
  
}

variable "nsg_resource_group" {
    type = string
    description = "Network security group resource group name"
  
}

variable "association_subnet_id" {
    type = string
    description = "List of string subnet ids"
  
}
variable "nsg_dependecy" {
    type = any
  
}