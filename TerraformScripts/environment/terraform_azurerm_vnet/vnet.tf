
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
  location            = var.vnet_location
  address_space       = [var.vnet_address_prefix]

  depends_on = [
    var.vnet_rg
  ]
}


resource "azurerm_subnet" "subnets" {
  for_each = toset(var.subnet_names) 
  name                 = each.key
  resource_group_name  = var.vnet_resource_group
  virtual_network_name = var.vnet_name
  address_prefixes     = [cidrsubnet(var.vnet_address_prefix,8,index(tolist(var.subnet_names),each.key))]

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
