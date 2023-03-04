resource "azurerm_resource_group" "drrg" {
  name = var.dr-rg-name
  location = var.dr-rg-location
}