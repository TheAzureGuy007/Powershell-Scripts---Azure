﻿$resourceGroup = "test2ResourceGroup"
$location = "westcentralus"
$vmName = "mytest1VM"
$securePassword = ConvertTo-SecureString '************'

$cred = New-Object System.Management.Automation.PSCredential ("testvm1", $securePassword)

New-AzureRmResourceGroup -Name $resourceGroup -Location $location

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name mytest1Subnet -AddressPrefix 192.168.1.0/24
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location -Name MYtest1vNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location -Name "mypublicdns$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4
$nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH  -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location -Name myNetworkSecurityGroup -SecurityRules $nsgRuleSSH
$nic = New-AzureRmNetworkInterface -Name myNic -ResourceGroupName $resourceGroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Basic_A1 | Set-AzureRmVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred | Set-AzureRmVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 16.04-LTS -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig