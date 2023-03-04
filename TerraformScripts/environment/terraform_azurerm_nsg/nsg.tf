
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.nsg_location
  resource_group_name = var.nsg_resource_group

  security_rule {
    name                       = "vmsecurity"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
  }
  depends_on = [
       var.nsg_dependecy
  ]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 =  var.association_subnet_id
  network_security_group_id =  azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}