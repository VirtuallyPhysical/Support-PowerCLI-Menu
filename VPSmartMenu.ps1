#####################################Preset Variables######################################

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$utilsDir  = Join-Path -Path $scriptDir -ChildPath \utils
$RefDir  = Join-Path -Path $scriptDir -ChildPath \RefMaterial

#####################################DEFINE FUNCTIONS#######################################

#Define vCenters
function VPF-Select-vCenter
{
    param (
        [string]$SCLUTitle = 'Select vCenter'
    )
    Clear-Host
	Write-Host 
    Write-Host " ================ $SCLUTitle ================" -ForegroundColor green
    Write-Host 
    Write-Host " 1: SPAV0100.flprod.co.uk" 
    Write-Host " 2: Specify FQDN" 
    Write-Host " 3: N/A"
	Write-Host 
}
clear
#Select & Connect to vCenter
function VPF-Choice-Select-vCenter
{
VPF-Select-vCenter –Title 'Select vCenter'
$selection = Read-Host " Please make a selection"
 switch ($selection)
  {
     '1' {
		 clear
         $VCChoice = "SPAV0100.flprod.co.uk"
		 write-host
		 write-host " You chose $VCChoice" -ForegroundColor yellow
		 Connect-VIServer $VCChoice
		 clear
		 VPF-Select-Datacenter
     } '2' {
		 Write-host
		 $selection = Read-Host " Please FQDN of VCSA or ESXi Host"
		 $VCChoice = $selection
		 Connect-VIServer $VCChoice
		 clear
		 VPF-Select-Datacenter
     } '3' {
         $VCChoice = "N/A"
		 write-host " You chose N/A, Goodbye!" -ForegroundColor red
		 Start-Sleep -Second 2
		 Exit
     } 
  }
 }
clear

#Select Datacenter
function VPF-Select-Datacenter
{
$datacenters = Get-datacenter
Write-Host
Write-Host " ================ Select Datacenter ================"  -ForegroundColor green
Write-Host
$i = 1
$datacenters | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
Write-Host
#Write-Host " V Check vCenter Services"
Write-Host " A Select All Datacenters"
Write-Host
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
         Disconnect-VIServer -Server * -Force
		 clear
		 VPF-Choice-Select-vCenter
}
if($selection -eq 'A'){
         $global:DCChoice = "*"
		 Write-Host " You chose Datacenter $DCChoice"
		 Clear
		 VPF-Select-Cluster
}
#if($selection -eq 'V'){
#         & $utilsDir\Get-vCenterServices.ps1
#		 Write-Host " You chose Datacenter $DCChoice"
#		 Clear
#		 VPF-Select-Cluster
#}
else{
		 $global:DCChoice = $datacenters[$selection -1].Name
		 Write-Host " You chose Datacenter $DCChoice"
		 Clear
		 VPF-Select-Cluster
}
}
#Select Cluster
function VPF-Select-Cluster
{
$clusters = Get-datacenter $DCChoice | Get-Cluster
Write-Host
Write-Host " ================ Select $DCChoice Cluster ================"  -ForegroundColor green
Write-Host
$i = 1
$clusters | ForEach-Object -Process {
    Write-Host " $i $($_.Name)"
	$i++
}
Write-Host
Write-Host " A Select All Clusters"
Write-Host
$selection = Read-Host " Please make a selection (Q to Quit)"

if($selection -eq 'Q'){
		 clear
         VPF-Select-Datacenter
}
if($selection -eq 'A'){
    $global:CLUChoice = "*"
	Write-Host
    Write-Host -NoNewLine " CAUTION! All further commands will be run against ALL clusters in DC $Global:DCChoice... Press any key to continue..." -ForegroundColor red;
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	Clear
	& $utilsDir\ListClusterCommands.ps1
}
else{
    $global:CLUChoice = $clusters[$selection -1].Name
    Write-Host " You chose cluster $CLUChoice"
	Start-Sleep -Second 1
	& $utilsDir\ListClusterCommands.ps1
}
}


#Disclaimer
function VPF-Disclaimer
{
$host.ui.RawUI.WindowTitle = “Virtually Physical Support Menu”
Write-Host
Write-Host " Be aware that all scripts are run at your own risk and while every script has been written with the intention of minimising the "
write-Host " potential for unintended consequences, the owners, hosting providers and contributers cannot be held responsible for any misuse or script problems."
write-Host -NoNewLine ' Run at your own risk! If you do not wish to continue, please close this window. Alternatively, press any key to continue...' -ForegroundColor red;
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
clear
VPF-Startup
}

#Startup
function VPF-Startup
{
	clear
	Import-Module VMware.PowerCLI -Verbose
	clear
	write-host
	write-host " Please enter a file path for exports" -ForegroundColor yellow
	$Global:FilePath = Read-Host " location" 
	Disconnect-VIServer -Force -server * -Confirm:$false
	clear

VPF-Choice-Select-vCenter
 }

#####################################Begin######################################

VPF-Disclaimer


