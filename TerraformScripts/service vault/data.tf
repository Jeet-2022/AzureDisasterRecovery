#Primary Site Resource group
data "azurerm_resource_group" "primary" {
  name = "testvnet"
}

#Secondary Site Resource group
data "azurerm_resource_group" "secondary" {
  name = "testvnet-secondary"
}

#Pulling virtual machine datas
data "azurerm_virtual_machine" "primary" {
 
  name                = "testvm0"
  resource_group_name = "testvnet"
}

#get network nic of vm0
data "azurerm_network_interface" "vm_nic" {
  name                = "testvm-nic0"
  resource_group_name = "testvnet"
}


#Pulling data from Secondary Virtual Network 
data "azurerm_virtual_network" "secondary" {
  name                = "testnetsecondary"
  resource_group_name = "testvnet-secondary"
}

#subnet of vm 0
data "azurerm_subnet" "secondary" {
  name                 = "subnet1"
  virtual_network_name = "testnetsecondary"
  resource_group_name  = "testvnet-secondary"
}
#Pulling data from Primary virtual network
data "azurerm_virtual_network" "primary" {
  name                = "testnet"
  resource_group_name = "testvnet"
}

data "azurerm_public_ip" "secondary" {
  name = "testvm-secondary-nic-pubip00"
  resource_group_name = "testvnet-secondary"
}

data "azurerm_managed_disk" "storage_os_disk" {
  name                = "vm-os-disk0"
  resource_group_name = "testvnet"
}