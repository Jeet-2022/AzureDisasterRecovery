resource "azurerm_public_ip" "example" {
  count = var.public_ip_count
  name                = "${var.public_ip_name}${count.index}"
  resource_group_name = var.public_ip_resourcegroup
  location            = var.public_ip_location
  allocation_method   = "Static"


  tags = {
    environment = "Dev"
  }
}