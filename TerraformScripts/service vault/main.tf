resource "azurerm_resource_group" "recoveryvault" {
  name     = "testvnet-recoveryvault"
  location = "Central US"
}

#Recovery service vault create in Central US
resource "azurerm_recovery_services_vault" "vault" {
  name                = "testvnet-recovery-vault"
  location            = azurerm_resource_group.recoveryvault.location
  resource_group_name = azurerm_resource_group.recoveryvault.name
  sku                 = "Standard"
}

#Primary Recovery fabric
resource "azurerm_site_recovery_fabric" "primary" {
  name                = "primary-fabric"
  resource_group_name = azurerm_resource_group.recoveryvault.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = data.azurerm_resource_group.primary.location
}

#Secondary Recovery fabric
resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "secondary-fabric"
  resource_group_name = azurerm_resource_group.recoveryvault.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = data.azurerm_resource_group.secondary.location
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "primary-protection-container"
  resource_group_name  = azurerm_resource_group.recoveryvault.name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "secondary-protection-container"
  resource_group_name  = azurerm_resource_group.recoveryvault.name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "policy"
  resource_group_name                                  = azurerm_resource_group.recoveryvault.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.vault.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.recoveryvault.name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}




resource "azurerm_site_recovery_network_mapping" "network-mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.recoveryvault.name
  recovery_vault_name         = azurerm_recovery_services_vault.vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
  source_network_id           = data.azurerm_virtual_network.primary.id
  target_network_id           = data.azurerm_virtual_network.secondary.id
}

resource "azurerm_storage_account" "primary" {
  name                     = "primaryrecoverycache3248"
  location                 = data.azurerm_resource_group.primary.location
  resource_group_name      = data.azurerm_resource_group.primary.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



# start repliction of the vm 
resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  name                                      = "vm-replication"
  resource_group_name                       = azurerm_resource_group.recoveryvault.name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = data.azurerm_virtual_machine.primary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = data.azurerm_resource_group.secondary.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = data.azurerm_managed_disk.storage_os_disk.id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = data.azurerm_resource_group.secondary.id
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }

  network_interface {
    source_network_interface_id   = data.azurerm_network_interface.vm_nic.id
    target_subnet_name            = data.azurerm_subnet.secondary.name
    recovery_public_ip_address_id = data.azurerm_public_ip.secondary.id
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container-mapping,
    azurerm_site_recovery_network_mapping.network-mapping,
  ]
}