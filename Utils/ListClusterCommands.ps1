#Define Cluster Options
function VPF-Cluster-Options
{
    param (
        [string]$CLUOTitle = "Cluster $global:DCChoice $Global:CLUChoice Options"
    )
    Clear-Host
    Write-Host
	Write-Host " ================ $CLUOTitle ================"  -ForegroundColor green
    Write-Host
    Write-Host "  1:  List Snapshots"
    Write-Host "  2:  List VMs"
    Write-Host "  3:  List Hosts"
	Write-Host "  4:  List Cluster Configuration"
	Write-Host "  5:  List Datastores"
	Write-Host "  6:  List Networks"
	Write-Host "  7:  Get Cluster Utilisation Summary "
	Write-Host "  8:  NUMA Report"
	Write-Host "  9:  Which Host should I deploy to"
	Write-Host " 10:  Which Datastore should I deploy to"
	Write-Host " 11:  List Provisioned Resources for $Global:CLUChoice"
	Write-Host
#	Write-Host " D:  Deploy & Configuration Menu"
	Write-Host "  V:  VM Menu"
	Write-Host " R1:  ESXTOP Guide"
	Write-Host " R2:  Clustering Deep Dive"
	Write-Host " R3:  Host Resources Deep Dive"
	Write-Host " R4:  6.5 best Practices"
	write-host
	write-host
	Write-Host " Q:  Press 'Q' to return to the previous menu." -ForegroundColor yellow
}
clear

# Select cluster commands to run
function VPF-Choice-Select-Cluster-Commands
{
VPF-Cluster-Options –Title 'Select command'
 Write-host
 $selection = Read-Host " Please make a selection"
 switch ($selection)
  {
     '1' {
		 'Getting Snapshots'
		 Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm | get-snapshot | select vm, name, description, created, sizegb | sort created | ft
		 Write-Host -NoNewLine 'Snapshots Exported. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm | get-snapshot | select vm, name, description, created, sizegb | sort created | export-csv -path "$Global:FilePath\$global:CLUChoice Snapshots $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
		 Clear
		 VPF-Choice-Select-Cluster-Commands
     } '2' {
         'List VMs'
		 Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm | select Name, NumCpu, MemoryMB, VMHost, UsedSpaceGB, ProvisionedSpaceGB, Notes | ft
		 Write-Host -NoNewLine 'VM List Exported. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm | select Name, NumCpu, MemoryMB, VMHost, UsedSpaceGB, ProvisionedSpaceGB, Notes | export-csv -path "$Global:FilePath\$global:CLUChoice VMs $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
		 Clear
		 VPF-Choice-Select-Cluster-Commands
     } '3' {
         'List Hosts'
		 Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-VMHost | Select Parent, Name, Version, Build, ConnectionState, PowerState, Model, ProcessorType, HyperthreadingActive, NumCpu, CpuTotalMhz, CpuUsageMhz, MemoryUsageGB, MemoryTotalGB | ft
		 Write-Host -NoNewLine 'Host List Exported. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-VMHost | Select Parent, Name, Version, Build, ConnectionState, PowerState, Model, ProcessorType, HyperthreadingActive, NumCpu, CpuTotalMhz, CpuUsageMhz, MemoryUsageGB, MemoryTotalGB | export-csv -path "$global:CLUChoice $global:FilePath\Hosts $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
		 Clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '4' {
         'List Cluster Configuration'
		 Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | select Name, VsanEnabled, DrsEnabled, DrsAutomationLevel, HAEnabled, HAAdmissionControlEnabled, VMSwapfilePolicy, EVCMode | ft
		 Write-Host -NoNewLine 'Cluster config Exported. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | select Name, VsanEnabled, DrsEnabled, DrsAutomationLevel, HAEnabled, HAAdmissionControlEnabled, VMSwapfilePolicy, EVCMode | export-csv -path "$global:FilePath\$global:CLUChoice Cluster Configuration $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
		 Clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '5' {
         'List Datastores'
	Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $Global:CLUChoice |
			Get-Datastore | Select Datacenter, Name, Type, CapacityGB,
			@{N='ProvisionedGB';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB)}},
			@{N='FreespaceGB';E={[math]::Round($_.FreespaceGB)}},
			@{N='Freespace%';E={[math]::Round(($_.FreespaceGB/$_.CapacityGB)*100,1)}},
			@{N='OverProvisioned';E={If ((($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB) -gt $_.CapacityGB) {"OverProvisioned"} Else {"Capacity Available"} }}, state  |
			Sort OverProvisioned | Where { $_.name -notlike "*-Local*"} | ft
		 Write-Host -NoNewLine 'Datastore list Exported. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
			Get-Datacenter $global:DCChoice | Get-Cluster $Global:CLUChoice |
			Get-Datastore | Select Datacenter, Name, Type, CapacityGB,
			@{N='ProvisionedGB';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB)}},
			@{N='FreespaceGB';E={[math]::Round($_.FreespaceGB)}},
			@{N='Freespace%';E={[math]::Round(($_.FreespaceGB/$_.CapacityGB)*100,1)}},
			@{N='OverProvisioned';E={If ((($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB) -gt $_.CapacityGB) {"OverProvisioned"} Else {"Capacity Available"} }}, state  |
			Sort OverProvisioned | Where { $_.name -notlike "*-Local*"} | ft | 
			export-csv -path "$global:FilePath\$global:CLUChoice Datastores $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
	Clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '6' {
         'List Networks'
		 Clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vmhost| get-virtualportgroup | Select Name, Key, VLanID | ft
		 Write-Host -NoNewLine " Press any key to continue...";
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '7' {
        'Get Cluster Resource Summary'
	  	 VPF-ClusterResources
	  	 clear
	  	 VPF-Choice-Select-Cluster-Commands
		 
     } '8' {
         'Numa Report'
		 & $utilsDir\NumaReport.ps1
		 clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '9' {
         'Which Host'
		 clear
		 VPF-WhichHost
		 clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '10' {
         'Which Datastore'
		 clear
		 WhichDatastoreShouldIUse
		 clear
		 VPF-Choice-Select-Cluster-Commands
		 
     } '11' {
         'List Resources'
		 clear
		ClusterProvisioned
		 
     } <# 'D' {
         'Deploy Menu'
	    Clear
	  	 & $utilsDir\DeployMenu.ps1
		 
     }#> 'V' {
         'VM Menu'
	 	 Clear
	 	 & $utilsDir\VMsMenu.ps1
	 	 
     } 'R1' {
         'VM Menu'
	 	 Clear
		 Start-Process ((Resolve-Path $RefDir\ESXTOP_vSphere6.pdf).Path)
		 clear
		 VPF-Choice-Select-Cluster-Commands
	 	 
     } 'R2' {
         'VM Menu'
	 	 Clear
		 Start-Process ((Resolve-Path $RefDir\ClusterDeepDive.pdf).Path)
	 	 clear
		 VPF-Choice-Select-Cluster-Commands
     } 'R3' {
         'VM Menu'
	 	 Clear
		 Start-Process ((Resolve-Path $RefDir\vSphere_65_Host_Resources_Deep_Dive.pdf).Path)	 	 
	 	 clear
		 VPF-Choice-Select-Cluster-Commands
     } 'R4' {
         'VM Menu'
	 	 Clear
		 Start-Process ((Resolve-Path $RefDir\Perf_Best_Practices_vSphere65.pdf).Path)	 	 
	 	 clear
		 VPF-Choice-Select-Cluster-Commands
     }  'q' {
		 Clear
         VPF-Select-Cluster
     }
  }
 }
clear 




#Get current usage statistics 
function VPF-VMstats
{
clear
Write-Host " On clusters with a large number of VMs, this will take a while to complete."
Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vm | Select Name, 
		@{N=“cpuAVG“;E={$_ | Get-stat -Stat cpu.usage.average -MaxSamples 1}}, 
		@{N=“cpuMhzAVG“;E={$_ | Get-stat -Stat cpu.usagemhz.average -MaxSamples 1}}, 
		@{N=“memUsageAVG“;E={$_ | Get-stat -Stat mem.usage.average -MaxSamples 1}}, 
		@{N=“memConsumedAVG“;E={$_ | Get-stat -Stat mem.consumed.average -MaxSamples 1}}, 
		@{N=“DiskUsageAVG“;E={$_ | Get-stat -Stat disk.usage.average -MaxSamples 1}}, 
		@{N=“DiskMaxTotalLatency“;E={$_ | Get-stat -Stat disk.maxTotalLatency.latest -MaxSamples 1}}, 
		@{N=“netUsageAVG“;E={$_ | Get-stat -Stat net.usage.average -MaxSamples 1}}, 
		@{N=“Uptime“;E={$_ | Get-stat -Stat sys.uptime.latest -MaxSamples 1}} | Sort cpuAVG | FT
	}
#Cluster Resources
function VPF-ClusterResources
{
clear
$days = 7
$start = (Get-Date).AddDays(- $days)
$stats = "cpu.usage.average","mem.usage.average"
write-host
Write-Host " Average over 7 days"
foreach ($cluster in Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice) {
    $esx = Get-VMHost -Location $cluster
    Get-Stat -Entity $esx -Start $start -Stat $stats |
    Group-Object -Property {$_.Entity.Name} |
    select @{N=" Cluster";E={$cluster.Name}},

        @{N=" VMHost";E={$_.Name}},
        @{N=" Total memory";E={$_.Group[0].Entity.MemoryTotalGB}},
        @{N=" Total CPU";E={$_.Group[0].Entity.NumCpu}},
        @{N=" Average memory used";E={$_.Group | Where {$_.MetricId -eq "mem.usage.average"} |
          Measure-Object -Property Value -Average | Select -ExpandProperty Average}},
        @{N=" Average CPU used";E={$_.Group | Where {$_.MetricId -eq "cpu.usage.average" -and $_.Instance -eq ""} |
          Measure-Object -Property Value -Average | Select -ExpandProperty Average}} | ft
}
		 Write-Host -NoNewLine " Press any key to continue...";
	  	 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	  	 Clear
}

function VPF-WhichHost {
    $whesx = Get-datacenter $global:DCChoice | Get-Cluster $Global:CLUChoice | Get-VMHost
    $memstats = Get-Stat -Entity $whesx -Stat "mem.usage.average" -Realtime -MaxSamples 1
	$memavg = $memstats | Measure-Object -Property Value -Average | Select -ExpandProperty Average 
	$cpustats = Get-Stat -Entity $whesx -Realtime -MaxSamples 1 | Where {$_.MetricId -eq "cpu.usage.average" -and $_.Instance -eq ""} 
	$cpuavg = $cpustats | Measure-Object -Property Value -Average | Select -ExpandProperty Average
	$BelAvgMemStats = $memstats | where{$_.Value -lt $memavg} | Select -ExpandProperty Entity
	$BelAvgCPUStats = $cpustats | where{$_.Value -lt $cpuavg} | Select -ExpandProperty Entity
	Write-Host
    Write-Host " ================ Which host to deploy to in $global:ClusterChoice ================" -ForegroundColor green
	write-host
	Write-Host " Below Average Mem" -ForegroundColor green
	write-host
	$BelAvgMemStats
	Write-Host
	Write-Host " Below Average CPU" -ForegroundColor green
	Write-Host
	$BelAvgCPUStats
	write-host
	Write-Host " All Below Average" -ForegroundColor green
		Write-Host
	#$BelAvgMemStats | where {$_.Name -Match $BelAvgCPUStats.Name} 
	(Compare-Object -ReferenceObject $BelAvgMemStats -DifferenceObject $BelAvgCPUStats -ExcludeDifferent -IncludeEqual).InputObject.Name
	write-host
		Write-Host -NoNewLine "Press any key to continue...";
	  	 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

Function WhichDatastoreShouldIUse
{
$DiskSize = Read-Host " Please Enter total disk size"
$RAMSize = Read-Host " Please Enter total RAM size"
$VMSize = [int]$DiskSize + [int]$RAMSize
$Available = {([int]$_.ProvisionedGB + [Int]$VMSize) -lt [Int]$_.CapacityGB -and $_.name -notlike "*-Local*"}

Get-Datacenter $global:DCChoice | Get-Cluster $Global:CLUChoice |
Get-Datastore | Select Datacenter, Name, Type, CapacityGB,
@{N='AfterProvisionedGB';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted + $VMSize)/1GB)}},
@{N='FreespaceGB';E={[math]::Round($_.FreespaceGB - $VMSize)}},
@{N='OverProvisioned';E={If ((($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted + $VMSize)/1GB) -gt $_.CapacityGB) {"OverProvisioned"} Else {"Capacity Available"} }}, state  |
Sort FreespaceGB | Where {([int]$_.AfterProvisionedGB + [Int]$VMSize) -lt [Int]$_.CapacityGB -and $_.name -notlike "*-Local*"} | ft
write-host		 
Write-Host -NoNewLine " Press any key to continue...";
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

Function ClusterProvisioned
{
$script:ClusterProvisioned = Get-Datacenter $global:DCChoice | Get-Cluster $Global:CLUChoice |
Select Name, HAEnabled, DRSEnabled,
@{N=“TotalCores“;E={
    $script:totalCores = Get-VMHost -Location $_ | Measure-Object NumCpu -Sum | Select -ExpandProperty Sum
    $script:totalCores}},
@{N=“ProvisionedCores“;E={
    $script:provisionedcores = Get-VMHost -Location $_ | get-vm | Measure-Object NumCpu -Sum | Select -ExpandProperty Sum
    $script:provisionedcores}},
@{N=“CoresRatio“;E={[math]::Round($script:provisionedcores/$script:totalcores,2)}},
@{N=“TotalMem“;E={
	$script:TotalMem = Get-VMHost -Location $_ | Measure-Object MemoryTotalGB -Sum | Select -ExpandProperty Sum
	[math]::Round($script:TotalMem)}},
@{N=“ProvisionedMem“;E={
	$script:ProvisionedMem = Get-VMHost -Location $_ | get-vm | Measure-Object MemoryGB -Sum | Select -ExpandProperty Sum
	$script:ProvisionedMem}},
@{N=“MemRatio“;E={[math]::Round($script:ProvisionedMem/$script:TotalMem,2)}}
$script:ClusterProvisioned | export-csv -path "$Global:FilePath\$global:CLUChoice Resources Provisioned $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
$script:ClusterProvisioned | FT
write-host
		Write-Host -NoNewLine " Press any key to continue...";
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 clear
		 VPF-Choice-Select-Cluster-Commands
}

#################################################################################################

VPF-Choice-Select-Cluster-Commands