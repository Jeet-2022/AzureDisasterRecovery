#Primary region resource group

resource "azurerm_resource_group" "rg" {
  name = "testvnet"
  location = "West Us 3"
  
}

resource "azurerm_resource_group" "rg_secondary" {
  name = "testvnet-secondary"
  location = "East Us"
  
}


#deploying primary virtual network vnet module
module "vnet" {
  source = "./terraform_azurerm_vnet"
  vnet_resource_group = azurerm_resource_group.rg.name
  vnet_location = azurerm_resource_group.rg.location
  vnet_name = "testnet"
  vnet_address_prefix = "10.0.0.0/21"
  subnet_names =  ["subnet1", "subnet2"]
  vnet_rg = azurerm_resource_group.rg
  
}


#deploying secondary region virtual network module
module "vnet_secondary" {
  source = "./terraform_azurerm_vnet"
  vnet_resource_group = azurerm_resource_group.rg_secondary.name
  vnet_location = azurerm_resource_group.rg_secondary.location
  vnet_name = "testnetsecondary"
  vnet_address_prefix = "10.1.0.0/21"
  subnet_names =  ["subnet1", "subnet2"]
  vnet_rg = azurerm_resource_group.rg_secondary
  
}

#primary region windows machines
module "window_vm" { 
  source = "./terraform_azurerm_virtualmachine"
  vm_name = "testvm"
  vm_location = "westus3"
  vm_resource_group = "testvnet"
  vm_size = "Standard_DS1_v2"
  vm_username = "testvm"
  vm_password = "Welcome@1234"
  nic_name = "testvm-nic"
  vm_subnetId = module.vnet.vm_subnet_id
  vm_count = 3
  nic_vm_dependecy = module.vnet
}

module "secondarypubIP" {
  source = "./terraform_public_ip"
  public_ip_name = "testvm-secondary-nic-pubip0"
  public_ip_resourcegroup = "testvnet-secondary"
  public_ip_location = "East Us"
  public_ip_count = 2
  
}

#Network security groups for primary VMs
module "vm_nsg" {
  source = "./terraform_azurerm_nsg"
  nsg_name = "testvm-security"
  nsg_location = "westus3"
  nsg_resource_group = "testvnet"
  association_subnet_id = element(module.vnet.vm_subnet_id,0)
  nsg_dependecy = module.window_vm
}



###Azure Automation account


resource "azurerm_automation_account" "AAA-monitoring-service" {
  name                = "AAA-monitoring"
  location            = "South Central US"
  resource_group_name = "monitoring"
  sku_name            = "Basic"

  tags = {
    environment = "development"
  }
}

resource "azurerm_log_analytics_workspace" "inframonitoring" {
  name                = "inframonitoring"
  location            = azurerm_automation_account.AAA-monitoring-service.location
  resource_group_name = azurerm_automation_account.AAA-monitoring-service.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_linked_service" "example" {
  resource_group_name = azurerm_log_analytics_workspace.inframonitoring.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.inframonitoring.id
  read_access_id      = azurerm_automation_account.AAA-monitoring-service.id
}

