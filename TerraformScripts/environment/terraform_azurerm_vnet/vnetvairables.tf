variable "vnet_name" {
  type = string
  description = "value"
}

variable "vnet_location" {
  type = string
  description = "value"
}

variable "vnet_resource_group" {
  type = string
  description = "value"
}

variable "vnet_address_prefix" {
  type = string
  description = "value"  
}

variable "subnet_names" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
}
variable "vnet_rg" {
  type = any
  
}