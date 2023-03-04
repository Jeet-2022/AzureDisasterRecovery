#This runbook prompts the user to enter the source and target resource group names, 
#        source and target virtual machine names, and performs the following steps:

#        -Connects to Azure
#        -Gets the source and target virtual machines
#        -Checks if the source and target virtual machines exist
#        -Gets the source and target virtual networks
#        -Replicates the virtual machine
#        -Checks the replication status
#         Note: This is just an example and you may need to modify it to match your specific requirements.

# Get the source and target resource groups
$srcResourceGroup = Read-Host -Prompt "Enter the source resource group name"
$targetResourceGroup = Read-Host -Prompt "Enter the target resource group name"

# Get the source and target virtual machines
$srcVM = Read-Host -Prompt "Enter the source virtual machine name"
$targetVM = Read-Host -Prompt "Enter the target virtual machine name"

# Connect to Azure
Connect-AzAccount

# Get the source and target virtual machines
$srcVmObj = Get-AzVM -Name $srcVM -ResourceGroupName $srcResourceGroup
$targetVmObj = Get-AzVM -Name $targetVM -ResourceGroupName $targetResourceGroup

# Check if the source virtual machine exists
if ($srcVmObj -eq $null) {
    Write-Output "The source virtual machine does not exist."
}

# Check if the target virtual machine exists
if ($targetVmObj -eq $null) {
    Write-Output "The target virtual machine does not exist."
}

# Get the source and target virtual networks
$srcVnet = Get-AzVirtualNetwork -Name $srcVmObj.NetworkProfile.NetworkInterfaces[0].IpConfigurations[0].Subnet.Id.Split("/")[8] -ResourceGroupName $srcResourceGroup
$targetVnet = Get-AzVirtualNetwork -Name $targetVmObj.NetworkProfile.NetworkInterfaces[0].IpConfigurations[0].Subnet.Id.Split("/")[8] -ResourceGroupName $targetResourceGroup

# Replicate the virtual machine
Start-AzSiteRecoveryReplication -SourceVirtualMachineId $srcVmObj.Id -TargetResourceGroupId $targetResourceGroup -TargetVirtualNetworkId $targetVnet.Id

# Check the replication status
Get-AzSiteRecoveryReplication -SourceVirtualMachineId $srcVmObj.Id
