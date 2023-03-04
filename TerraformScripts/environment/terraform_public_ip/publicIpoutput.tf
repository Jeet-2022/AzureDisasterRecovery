output "public_address_id" {
  value = [for s in azurerm_public_ip.example : s.id]
}