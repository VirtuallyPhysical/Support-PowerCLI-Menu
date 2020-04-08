#####################################################
function VPF-Select-Datastore
{
write-host
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-datastore
$global:datastorechoice = Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-datastore
Write-Host
Write-Host " ================ Select Datastore ================"  -ForegroundColor green
Write-Host
$i = 1
$global:datastorechoice | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
Write-Host
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		clear
         & $utilsDir\DeployMenu.ps1
}
else{
    $Global:NewVMDatastore = $global:datastorechoice[$selection -1].Name
    Write-Host " You chose datastore $NewVMDatastore"
	Clear
	
}
}
####################################################
function VPF-Select-Host
{
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-VMHost
write-host
$global:hostchoice = Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vmhost
Write-Host
Write-Host " ================ Select Host ================"  -ForegroundColor green
Write-Host
$i = 1
$global:hostchoice | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
Write-Host
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		clear
         & $utilsDir\DeployMenu.ps1
}
else{
    $Global:NewVMHost = $global:hostchoice[$selection -1].Name
	
    Write-Host " You chose Host $NewVMHost"
	Clear

}
}
######################################################
function VPF-Select-Network
{
$Global:networkschoice = get-virtualportgroup -VMhost $Global:NewVMHost | Select Name
Write-Host
Write-Host " ================ Select Network ================"  -ForegroundColor green
Write-Host
$i = 1
$Global:networkschoice | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
Write-Host
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		clear
         & $utilsDir\DeployMenu.ps1
}
else{
    $Global:NewVMNetwork = $Global:networkschoice[$selection -1].Name
	
    Write-Host " You chose Host $NewVMHost"
	Clear

}
}

function VPF-NewVM
{
write-host
$NewVMName = Read-Host " Please Enter New VM Name"
$NewVMMem = Read-Host " Please Enter number of vCPU"
$NewVMCPU = Read-Host " Please Enter amount of RAM"
VPF-Select-Host
clear
	VPF-Select-Datastore
clear
	$NewVMDisk = Read-Host " Please Enter size of disk 1 (GB)"
clear
	VPF-Select-Network
			New-VM -Name $NewVMName –VMHost $NewVMHost -Datastore $NewVMDatastore -DiskGB $NewVMDisk -MemoryGB $NewVMMem -NumCpu $NewVMCPU -NetworkName $Global:NewVMNetwork
	
		 Write-Host -NoNewLine 'VM Container Deploying. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
& $utilsDir\DeployMenu.ps1
} 

########################################################################################################################################################################
clear
VPF-NewVM
  
