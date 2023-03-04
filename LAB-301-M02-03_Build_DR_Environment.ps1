<#	
	Version:        1.0
	Author:         Ahmad Majeed Zahoory
	Creation Date:  26th February, 2020
	Purpose/Change: Build DR Environment

#>

############################################ PR Virtual Network ######################################################

# Variables for common values
$resourceGroup1 = "RG-301-M02-03-R1"
$location1 = "eastus"

# Definer user name and password
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup1 -Location $location1

# Create a virtual network with subnet
$subnet = New-AzVirtualNetworkSubnetConfig -Name 'PRSubnet' -AddressPrefix '192.168.0.0/24'
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup1 -Name 'PR-VNeT' -AddressPrefix '192.168.0.0/24' `
  -Location $location1 -Subnet $subnet

############################################ DR Virtual Network ######################################################

# Variables for common values
$resourceGroup2 = "RG-301-M02-03-R2"
$location2 = "eastus2"

# Create a resource group
New-AzResourceGroup -Name $resourceGroup2 -Location $location2

# Create a virtual network with subnet
$subnet2 = New-AzVirtualNetworkSubnetConfig -Name 'DRSubnet' -AddressPrefix '192.168.0.0/24'
$vnet2 = New-AzVirtualNetwork -ResourceGroupName $resourceGroup2 -Name 'DR-VNeT' -AddressPrefix '192.168.0.0/24' `
  -Location $location2 -Subnet $subnet2


############################################ PR Caching Storage ######################################################

$SkuName = "Standard_LRS"
$Prefix = "LAB301"

#Create Storageaccount
function New-RandomName {
( -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))
}
do {
        $SARandomName = New-RandomName
        $SAName = ($Prefix + $SARandomName).ToLower()
        $Availability = Get-AzStorageAccountNameAvailability -Name $SAName
    }
while ($Availability.NameAvailable -eq $false)
    
New-AzStorageAccount -ResourceGroupName $resourceGroup1 -Name $SAName -Location $location1 -SkuName $SkuName

############################################ Red Hat Web Server ######################################################

# Create a public IP address and specify a DNS name
$pip1 = New-AzPublicIpAddress -ResourceGroupName $resourceGroup1 -Location $location1 -Name "websrvdns$(Get-Random)" -AllocationMethod Dynamic -IdleTimeoutInMinutes 4

# Create a nic for vm
$nicvm1 = New-AzNetworkInterface -ResourceGroupName $resourceGroup1 -Location $location1 -Name 'nicvm1' -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip1.Id

# Create a virtual machine configuration
$vmConfig1 = New-AzVMConfig -VMName PR-Web-SRV -VMSize Standard_DS1_v2 | `
Set-AzVMOperatingSystem -Linux -ComputerName PR-Web-SRV -Credential $cred | `
Set-AzVMSourceImage -PublisherName RedHat -Offer RHEL -Skus 7.6 -Version latest | `
Add-AzVMNetworkInterface -Id $nicvm1.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup1 -Location $location1 -VM $vmConfig1

# Install WebServer using custom script extension 
$PublicSettings = '{"fileUris":["https://raw.githubusercontent.com/ahmadzahoory/az301template/master/az-301-02-03-web-script.sh"],"commandToExecute":"sh az-301-02-03-web-script.sh"}'

Set-AzVMExtension -ExtensionName "BashCustomScript" -ResourceGroupName $resourceGroup1 -VMName PR-Web-SRV `
  -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
  -SettingString $PublicSettings `
  -Location $location1

############################################ Red Hat MySQL Server ######################################################

# Create a public IP address and specify a DNS name
$pip2 = New-AzPublicIpAddress -ResourceGroupName $resourceGroup1 -Location $location1 -Name "dbsrvdns$(Get-Random)" -AllocationMethod Dynamic -IdleTimeoutInMinutes 4

# Create a nic for vm
$nicvm2 = New-AzNetworkInterface -ResourceGroupName $resourceGroup1 -Location $location1 -Name 'nicvm2' -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip2.Id

# Create a virtual machine configuration
$vmConfig2 = New-AzVMConfig -VMName PR-DB-SRV -VMSize Standard_DS1_v2 | `
Set-AzVMOperatingSystem -Linux -ComputerName PR-DB-SRV -Credential $cred | `
Set-AzVMSourceImage -PublisherName RedHat -Offer RHEL -Skus 7.6 -Version latest | `
Add-AzVMNetworkInterface -Id $nicvm2.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup1 -Location $location1 -VM $vmConfig2

# Install WebServer using custom script extension 
$PublicSettings = '{"fileUris":["https://raw.githubusercontent.com/ahmadzahoory/az301template/master/az-301-02-03-db-script.sh"],"commandToExecute":"sh az-301-02-03-db-script.sh"}'

Set-AzVMExtension -ExtensionName "BashCustomScript" -ResourceGroupName $resourceGroup1 -VMName PR-DB-SRV `
  -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
  -SettingString $PublicSettings `
  -Location $location1


#End