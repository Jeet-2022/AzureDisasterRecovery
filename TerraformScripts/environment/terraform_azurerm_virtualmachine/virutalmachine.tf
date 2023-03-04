module "pubIP" {
 source = "../terraform_public_ip"
 public_ip_count = var.vm_count
 public_ip_location = var.vm_location
 public_ip_name = "${var.nic_name}-pubip"
 public_ip_resourcegroup = var.vm_resource_group
 depends_on = [
   var.nic_vm_dependecy
 ]
}
#Adding NIC and a windows virtual machine

resource "azurerm_network_interface" "testvm_nic" {
 
 
 count = var.vm_count
  name                = "${var.nic_name}${count.index}"
  location            = var.vm_location
  resource_group_name =  var.vm_resource_group
 
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${var.vm_subnetId[count.index % 2]}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  module.pubIP.public_address_id[count.index]
  }
  depends_on = [
        var.nic_vm_dependecy
    ]
}



#creat Windows Virtual machine
resource "azurerm_virtual_machine" "testvm" {
  count = var.vm_count
  name                   = "${var.vm_name}${count.index}"
  resource_group_name    = var.vm_resource_group
  location               = var.vm_location
  vm_size                = var.vm_size
  network_interface_ids  = [azurerm_network_interface.testvm_nic[count.index].id]
 storage_image_reference {
   publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
 
  storage_os_disk {
    name              = "vm-os-disk${count.index}"
    os_type           = "Windows"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

   os_profile {
    computer_name  = "testvm${count.index}"
    admin_username = "${var.vm_username}${count.index}"
    admin_password = var.vm_password
    
  }
   os_profile_windows_config {
    provision_vm_agent = true
   }
  depends_on = [
    azurerm_network_interface.testvm_nic
  ]
}