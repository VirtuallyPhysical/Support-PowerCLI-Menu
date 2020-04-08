############################################VM MENU############################################

function VPF-VM-Menu
{
    param (
        [string]$VMTitle = "Select $global:DCChoice $Global:CLUChoice option"
    )
    Clear-Host
	Write-Host
    Write-Host " ================ $VMTitle ================"  -ForegroundColor green
    Write-Host
    Write-Host "  1: Last 10 VMs created, cloned or imported"
    Write-Host "  2: Last 5 VMs removed"
	Write-Host "  3: List VMs in cluster $Global:CLUChoice with alarms"
    Write-Host "  4: List VMs on local storage"
    Write-Host "  5: List VMs Average Resources"
    Write-Host "  6: List VMs NIC & MAC Address"
    Write-Host "  7: Find VM by its MAC Address - Format: XX:XX:XX:XX:XX:XX"
   #Write-Host "  8: Tag VMs by Service Group from csv (Doesnt currently work)" -ForegroundColor red
	Write-Host "  9: Check for old VM Hardware Versions"
	Write-host " 10: List all Powered Off VMs"
	Write-host " 11: Set VM Notes"
	Write-host " 12: List VMware Tools Version & Status"
	Write-host " 13: Take a Snapshot"
	Write-host
	Write-Host " Q: Return to cluster Options" -ForegroundColor yellow
}
clear
#Select & Connect to vCenter
function VPF-Choice-VM-MENU
{
VPF-VM-Menu –Title 'Select option'
Write-host
$selection = Read-Host " Please make a selection"
 switch ($selection)
  {
     '1' {
		 clear
		 VPF-Last10VMCreated
     } '2' {
		 clear
		 VPF-Last5VMRemoved
     } '3' {
		 clear
		 VPF-ListVMAlarms
		
     } '4' {
		 clear
		 VPF-VMLocalStorage
     } '5' {
		 clear
		 VPF-VMAvgResource
     } '6' {
		 clear
		 VPF-ListVMMac
     } '7' {
		 clear
		 VPF-MACFindVM
     } '8' {
		 clear
		 VPF-Choice-VM-MENU
     } '9' {
		 clear
		 VPF-OldVMHw
     } '10' {
		 clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-vm  | where {$_.PowerState -match "PoweredOff"} | select name, PowerState, NumCPU, MemoryGB, ProvisionedSpaceGB, UsedSpaceGB, Notes | ft
		 Write-Host -NoNewLine 'Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-vm  | where {$_.PowerState -match "PoweredOff"} | select name, PowerState, NumCPU, MemoryGB, ProvisionedSpaceGB, UsedSpaceGB, Notes | Export-Csv -Path "$Global:FilePath\$global:CLUChoice Powered Off VMs $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
		 VPF-Choice-VM-MENU
     } '11' {
		 clear
		 VPF-SetVMNotes
     } '12' {
		 clear
		 VPF-GetVMToolsVersion
     } '13' {
		 clear
		 VPF-TakeSnapshot
     } 'Q' {
         & $utilsDir\ListClusterCommands.ps1
		 
     } 
  }
 }
clear

############################################ Functions ############################################

#last 10 VMs created, cloned or imported
function VPF-Last10VMCreated
{
Get-VIEvent -maxsamples 10000 |where {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"} |Sort CreatedTime -Descending |Select CreatedTime, UserName,FullformattedMessage -First 10
	
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
VPF-Choice-VM-MENU	
}

#last 5 VMs removed
function VPF-Last5VMRemoved
{
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-VIEvent -maxsamples 10000 | where {$_.Gettype().Name -eq "VmRemovedEvent"} | Sort CreatedTime -Descending | Select CreatedTime, UserName, FullformattedMessage -First 19 | ft
	
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
VPF-Choice-VM-MENU		
}

#List VMs on local storage
function VPF-VMLocalStorage
{
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-Datastore | where {$_.Name -match “local“} | Get-VM | Get-HardDisk | select Filename, CapacityGB | ft
	
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	
Get-Datastore |where {$_.Name -match “local“} |Get-VM |Get-HardDisk |select Filename |Export-Csv - Path "$Global:FilePath\$global:CLUChoice VMLocalStorage $(get-date -f yyyy-MM-dd-hhmm).csv"
clear	
VPF-Choice-VM-MENU	
}
#List All VM inc MAC Address
function VPF-ListVMMac
{
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-vm | Select Name, @{N=“NIC“;E={$_ | Get-networkAdapter | select  -ExpandProperty Name}}, @{N=“MAC“;E={$_ | Get-networkAdapter | select -ExpandProperty MacAddress}} | Export-Csv -Path "$Global:FilePath\$global:CLUChoice VMNicMac $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-vm | Select Name, @{N=“NIC“;E={$_ | Get-networkAdapter | select  -ExpandProperty Name}}, @{N=“MAC“;E={$_ | Get-networkAdapter | select -ExpandProperty MacAddress}} | ft
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear	
VPF-Choice-VM-MENU	
}
#Find VM by its MAC Address
function VPF-MACFindVM
{
$MacAddress = Read-Host "Please enter MAC address"
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-vm | Get-networkAdapter | Where {$_.MacAddress -like "$MacAddress"} | Select Parent, Name, NetworkName, MacAddress
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear	
VPF-Choice-VM-MENU	
}

#List VMs Average Resources
function VPF-VMAvgResource
{
$VMName = Read-host " Enter your VMs name"
$VMSTATS = Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm $VMName | Select Name, 
	@{N=“cpuAVG%“;E={$_ | Get-stat -Stat cpu.usage.average -MaxSamples 1}}, 
	@{N=“cpuMhzAVG“;E={$_ | Get-stat -Stat cpu.usagemhz.average -MaxSamples 1}}, 
	@{N=“memUsageAVG%“;E={$_ | Get-stat -Stat mem.usage.average -MaxSamples 1}}, 
	@{N=“memConsumedAVG“;E={$_ | Get-stat -Stat mem.consumed.average -MaxSamples 1}}, 
	@{N=“DiskUsageAVG“;E={$_ | Get-stat -Stat disk.usage.average -MaxSamples 1}}, 
	@{N=“DiskMaxTotalLatency“;E={$_ | Get-stat -Stat disk.maxTotalLatency.latest -MaxSamples 1}}, 
	@{N=“netUsageAVG“;E={$_ | Get-stat -Stat net.usage.average -MaxSamples 1}}, 
	@{N=“Uptime“;E={$_ | Get-stat -Stat sys.uptime.latest -MaxSamples 1}} 
$VMSTATS | Sort cpuAVG | FT
Write-Host -NoNewLine ' Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
write-host
Write-Host " Exporting CSV"
$VMSTATS | Sort cpuAVG | Export-Csv -Path "$Global:FilePath\$global:CLUChoice AVG VM Resources $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
VPF-Choice-VM-MENU
}
 
#Tag my VMs
function VPF-TagMyVMs
{ 
#Define CSV location
Write-Host " CSV columns need to be labeled Container , VMName" -ForegroundColor green
Write-Host " Container name should be tier specific within a Service Group" -ForegroundColor green
Write-Host " Tag category will be the folder name (Service Group) that contains Container (Tier) sub folders " -ForegroundColor green
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
$csvPath = Read-Host "Please enter csv location e.g C:\temp\test.csv"
$taginfo = Import-CSV $csvPath

#Create & Apply Tags
ForEach ($item in $taginfo)
{
$Container = $item.Container
$Name = $item.VMName
Write-Host ".... Assigning Tag to Category $category"
Get-TagCategory -Name $Category | New-Tag -Name $Container | Out-Null
Write-Host ".... Assigning Tag in Category $category to $Name "
Get-Folder $Container | Get-VM | New-TagAssignment -Tag $Container | Out-Null
}
VPF-Choice-VM-MENU
}

#Check for old VM Hardware Versions 
function VPF-OldVMHw
{
Write-Host
Write-Host " ================ Select VM Version ================"  -ForegroundColor green
write-host
Write-Host " Virtual Hardware Version	Products"
Write-Host
Write-Host "		15				ESXi 6.7U2"
Write-Host "		14				ESXi 6.7"
Write-Host "		13				ESXi 6.5"
Write-Host "		11				ESXi 6.0"
Write-Host "		10				ESXi 5.5"
Write-Host "		 9				ESXi 5.1"
Write-Host
$selection = Read-Host " Please enter the expected Virtual Hardware Version (Q to quit)"
if($selection -eq 'Q'){
		 clear
         VPF-Choice-VM-MENU
 }
else{
		Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-VM | Get-View | Where {$_.Config.Version -lt "vmx-$selection"} | Select Name | Sort Name | ft
		Write-Host -NoNewLine 'Press any key to continue...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-VM | Get-View | Where {$_.Config.Version -lt "vmx-$selection"} | Select Name | Sort Name | Export-Csv -Path "$Global:FilePath\$global:CLUChoice Old Hardware Versions $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
 }
 VPF-Choice-VM-MENU
}

#List VMs with alarms
function VPF-ListVMAlarms
{
$VMs = Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | get-vm | Get-View -Property Name,OverallStatus,TriggeredAlarmstate
$FaultyVMs = $VMs | Where-Object {$_.OverallStatus -ne "Green"}

$progress = 1
$report = @()
if ($FaultyVMs -ne $null) {
    foreach ($FaultyVM in $FaultyVMs) {
            foreach ($TriggeredAlarm in $FaultyVM.TriggeredAlarmstate) {
                Write-Progress -Activity "Gathering alarms" -Status "Working on $($FaultyVM.Name)" -PercentComplete ($progress/$FaultyVMs.count*100) -Id 1 -ErrorAction SilentlyContinue
                $alarmID = $TriggeredAlarm.Alarm.ToString()
                $object = New-Object PSObject
                Add-Member -InputObject $object NoteProperty VM $FaultyVM.Name
                Add-Member -InputObject $object NoteProperty TriggeredAlarms ("$(Get-AlarmDefinition -Id $alarmID)")
                $report += $object
            }
        $progress++
        }
    }
Write-Progress -Activity "Gathering VM alarms" -Status "All done" -Completed -Id 1 -ErrorAction SilentlyContinue

$report | Where-Object {$_.TriggeredAlarms -ne ""} | ft

	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
VPF-Choice-VM-Menu
}

#Set multiple VM notes from csv
function VPF-SetVMNotes
{
$CSVLocation = Read-Host " Please enter the CSV path"
Get-Content -Path $CSVLocation | ConvertFrom-Csv -Header VMName,Notes | %{

Get-VM -Name $_.VMName | Set-VM -Notes $_.Notes -Confirm:$false

}
clear
VPF-Choice-VM-MENU	
}

#Set multiple VM notes from csv
function VPF-GetVMToolsVersion
{
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | Get-VM | Select-Object -Property Name,@{Name='Tools Version';Expression={$_.Guest.ToolsVersion}},@{Name='Tools Status';Expression={$_.ExtensionData.Guest.ToolsStatus}} | sort 'Tools Status'
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
VPF-Choice-VM-MENU	
}

#Take a Snapshot
Function VPF-TakeSnapshot
{
$CU = $global:DefaultVIServer.User
$VM = Read-Host " Please enter a VM name"
write-host
get-vm $VM | select Name, notes 
write-host
$CorrectVM = Read-Host " Is this the correct VM? (Y/N)"
IF ($CorrectVM -eq "Y") {
	clear
	$Ticket = Read-Host " Please enter a Ticket Number"
	$Description = Read-Host " Please enter a snapshot Description"
	New-Snapshot -VM $VM -Name "$CU - $Ticket - $(get-date -f yyyy-MM-dd)" -Description "$Description"
		Write-Host -NoNewLine " Snapshot Complete, Press any key to continue...";
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	}
Else {
		$VMs = get-vm $VM
		Write-Host
		Write-Host " ================ Select VM ================"  -ForegroundColor green
		Write-Host
		$i = 1
		$VMs | ForEach-Object -Process {
		Write-Host " $i $($_.Name)  $($_.Notes) "
		$i++
	}
		Write-Host
		Write-Host
		$selection = Read-Host " Please make a selection (Q to Quit)"

	if($selection -eq 'Q'){
		 clear
         Exit
}
	else{
    $VMChoice = $VMs[$selection -1].Name
	$Ticket = Read-Host " Please enter a Ticket Number"
	$Description = Read-Host " Please enter a snapshot Description"
	New-Snapshot -VM $VM -Name "$CU - $Ticket - $(get-date -f yyyy-MM-dd)" -Description "$Description"
		Write-Host -NoNewLine " Snapshot Complete, Press any key to continue...";
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	}
 }
 clear
 VPF-Choice-VM-MENU
}

 ##############################################################################################################
 
 VPF-Choice-VM-MENU
 