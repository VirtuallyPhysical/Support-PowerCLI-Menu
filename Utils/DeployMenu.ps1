############################################DEPLOY MENU FUNCTIONS############################################

function VPF-Deploy-Menu
{
    param (
        [string]$DeployTitle = "Select $Global:CLUChoice option"
    )
    Clear-Host
	Write-Host
    Write-Host " ================ $DeployTitle ================"  -ForegroundColor green
    Write-Host
    Write-Host "  1: Add host to vCenter"
    Write-Host "  2: Place Host from cluster $Global:CLUChoice into Maintenance Mode"
	Write-Host "  3: Place Host from DC $Global:DCChoice into Maintenance Mode"
    Write-Host "  4: Exit Host from Maintenance Mode"
    Write-Host "  5: Copy vSwitch from an existing host to a new host"
    Write-Host "  3: Configure NTP for all hosts in cluster $Global:CLUChoice"
    Write-Host "  7: Configure Syslog for all hosts in cluster $Global:CLUChoice"
    Write-Host "  8: Select Host to move to cluster $Global:CLUChoice"
	Write-Host "  9: Add host to Active Directory (Doesnt currently work)" -ForegroundColor red
	Write-Host " 10: Check host domain auth status" 
	Write-Host " 11: List all DC $Global:DCChoice VMKernel Adapters"
	Write-Host " 12: Deploy a new VM (Doesnt currently work)" -ForegroundColor red
	Write-Host " 13: List host HBA & WWN"
	Write-Host " 14: Rename local datastore to Hostname-Local (Untested)" -ForegroundColor red
	Write-Host
	Write-Host " Q: Return to cluster Options" -ForegroundColor yellow
}
clear
#Select deployment commands
function VPF-Choice-Deploy-Menu
{
VPF-Deploy-Menu –Title 'Select option'
Write-host
$selection = Read-Host " Please make a selection."
 switch ($selection)
  {
     '1' {
		 clear
		 VPF-AddHostVC
		 Write-Host -NoNewLine ' Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 Get-VMHost -Name $NewHostFQDN | set-vmhost -State Maintenance	
		 VPF-Deploy-Menu
		 
     } '2' {
		 clear
		 VPF-HostInMaintMode
		 
     } '3' {
		 clear
		 VPF-DCHostInMaintMode
		 
     } '4' {
		 clear
		 VPF-HostOutMaintMode
		 
     } '5' {
		 clear
		  & $utilsDir\CopyvSwitch.ps1
     } '6' {
		 clear
		 $NTPServer = Read-Host " Please Enter NTP Server details"
		 Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | get-vmhost | Add-VMHostNtpServer -NtpServer $NTPServer
		 
     } '7' {
		 clear
		 $SyslogServer = Read-Host " Please Enter Syslog Server details"
		 Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | Get-VMHost | Set-VMHostSysLogServer -SysLogServer "$SyslogServer"
		 $global:DCChoice | Get-Cluster $global:CLUChoice | get-vmhost | get-vmhostsyslogserver
		 Write-Host -NoNewLine 'Complete. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 VPF-Deploy-Menu
		 
     } '8' {
		 clear
		 VPF-MoveHostCluster
		 Write-Host -NoNewLine ' Complete. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 
     } '9' {
		 clear
		 
		 VPF-Deploy-Menu
		 
     } '10' {
		 clear		 
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vmhost | Get-VMHostAuthentication | select -Property VMhost, @{N=”Domain”;E={$_.vmhost.Domain}},@{N=”DomainMembershipStatus”;E={$_.vmhost.DomainMembershipStatus}}
		 Write-Host -NoNewLine ' Complete. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 VPF-Deploy-Menu
		 
     } '11' {
		 clear
		 VPF-ListVMK
		 
     } '12' {
		 clear
		  & $utilsDir\DeployMenu.ps1
		 
     } '13' {
		 clear
		 Get-Datacenter $global:DCChoice | Get-Cluster $global:CLUChoice | get-vmhost | Get-VMHostHBA -Type FibreChannel | Select VMHost,Device,@{N=”WWN”;E={“{0:X}” -f $_.PortWorldWideName}}
		 Write-Host -NoNewLine ' Complete. Press any key to continue...';
		 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		 clear
		 VPF-Deploy-Menu
     } '14' {
		 clear
		 VPF-RenameLocalDatastores
		 clear
		 VPF-Deploy-Menu
     } 'Q' {
         & $utilsDir\ClusterCommands.ps1
		 
     } 
  }
}

#Add host to vCenter
function VPF-AddHostVC
{
$NewHostFQDN = Read-Host " Please Enter New Host FQDN"
$credentials = Get-Credential -UserName root -Message "Enter the ESXi root password"

	Add-VMHost -Name $NewHostFQDN -Location $global:DCChoice -User $credentials.UserName -Password $credentials.GetNetworkCredential().Password -RunAsync -force
	Write-Host " Adding ESXi host $ESXiHosts to vCenter" -ForegroundColor GREEN 
clear
VPF-Choice-Deploy-Menu
}

#Place host from this cluster into maintenance mode
function VPF-HostInMaintMode
{
$hosts = Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | get-vmhost | Where {$_.ConnectionState -ne "Maintenance"}
Write-Host " ================ Select host from $Global:CLUChoice to enter maintenance mode ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host "$i $($_.Name)"
	$i++
}
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
    Write-Host " You chose to place $HostChoice into maintenance mode"
	Start-Sleep -Second 1
	Get-VMHost -Name $HostChoice | set-vmhost -State Maintenance
	clear
	VPF-Choice-Deploy-Menu
}
}

#Place host from this DC into maintenance mode
function VPF-DCHostInMaintMode
{
$hosts = Get-datacenter $Global:DCChoice | get-vmhost | Where {$_.ConnectionState -ne "Maintenance"}
Write-Host " ================ Select host from DC $Global:DCChoice to enter maintenance mode ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host "$i $($_.Name)"
	$i++
}
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
    Write-Host " You chose to place $HostChoice into maintenance mode"
	Start-Sleep -Second 1
	Get-VMHost -Name $HostChoice | set-vmhost -State Maintenance
	clear
	VPF-Choice-Deploy-Menu
}
}

#take host out of maintenance mode
function VPF-HostOutMaintMode
{
$hosts = Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | get-vmhost | Where {$_.ConnectionState -eq "Maintenance"}
Write-Host " ================ Select host to enter maintenance mode ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
    Write-Host " You chose to take $HostChoice out of maintenance mode"
	Start-Sleep -Second 1
	Get-VMHost -Name $HostChoice | set-vmhost -State Connected
	clear
	VPF-Choice-Deploy-Menu
}
}


#Move host into current selected cluster
function VPF-MoveHostCluster
{
$hosts = Get-datacenter $Global:DCChoice | get-vmhost | Where {$_.ConnectionState -eq "Maintenance"}
Write-Host " ================ Select host to move ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
$selection = Read-Host "Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
    Write-Host " Moving $HostChoice into $Global:CLUChoice"
	Start-Sleep -Second 1
	Move-VMHost $HostChoice -Destination $Global:CLUChoice
	clear
	VPF-Choice-Deploy-Menu
}
}

#Add a single host to AD
function VPF-AddSingleHostAD
{
$hosts = Get-datacenter $Global:DCChoice | get-vmhost
Write-Host " ================ Select host to add to AD ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         VPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
	$domian_name = Read-Host ' Input the dns domain name'
    $credentials = Get-Credential -UserName root -Message "Enter AD Domain Credentials"
	Write-Host
	Write-Host " Adding chosen host to AD..."
	Write-Host
	Get-VMHostAuthentication -VMHost $HostChoice | Set-VMHostAuthentication -JoinDomain -Domain $domian_name -User $credentials.UserName -Password $credentials.GetNetworkCredential().Password
	Start-Sleep -Second 5
	clear
	VPF-Choice-Deploy-Menu
}
}

#Get host VMKs 
function VPF-ListVMK
{
$hosts = Get-datacenter $Global:DCChoice | get-vmhost 
Write-Host " ================ Get all Hosts in $Global:DCChoice VMkernel Adapters ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
	Get-Datacenter $global:DCChoice | get-vmhost | Get-VMHostNetworkAdapter -VMKernel | select VMhost, DeviceName, Mac, Mtu, DhcpEnabled, IP,SubnetMask, VMotionEnabled, FaultToleranceLoggingEnabled, ManagementTrafficEnabled, VsanTrafficEnabled | Sort VMhost  | ft
	Write-Host -NoNewLine 'VMK List Exported. Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	Get-Datacenter $global:DCChoice | get-vmhost | Get-VMHostNetworkAdapter -VMKernel | select VMhost, DeviceName, Mac, Mtu, DhcpEnabled, IP,SubnetMask, VMotionEnabled, FaultToleranceLoggingEnabled, ManagementTrafficEnabled, VsanTrafficEnabled | Sort VMhost | Export-Csv -Path "$Global:FilePath\DCVMKList $(get-date -f yyyy-MM-dd-hhmm).csv" -NoTypeInformation
	clear
	VPF-Choice-Deploy-Menu
}
}

#Rename host datastore to hostname-local
function VPF-RenameLocalDatastores
{
$hosts = Get-datacenter $Global:DCChoice | Get-Cluster $Global:CLUChoice | get-vmhost
Write-Host " ================ Select host to change local datastore name ================" -ForegroundColor green

$i = 1
$hosts | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
$selection = Read-Host "Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         TVPF-Choice-Deploy-Menu
}
else{
    $HostChoice = $hosts[$selection -1].Name
    get-vmhost -name $HostChoice | Get-Datastore | where {$_.name -like "datastore1"} | Set-Datastore -name $_.DSname
	Write-Host -NoNewLine 'Complete. Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	clear
	VPF-Choice-Deploy-Menu
}
}



############################################BEGIN############################################

VPF-Choice-Deploy-Menu



