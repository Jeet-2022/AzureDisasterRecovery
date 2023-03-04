output "vm_subnet_id" {
  value = [for s in azurerm_subnet.subnets : s.id]
}

output "primary_vnet" {
  value = azurerm_virtual_network.vnet.name
}

